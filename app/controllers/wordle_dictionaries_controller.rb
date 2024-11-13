class WordleDictionariesController < ApplicationController
  before_action :check_session_id

  # GET /wordle_dictionaries or /wordle_dictionaries.json
  def index
    if request.format.json?
      @wordle_dictionaries = WordleDictionary
        .where('word LIKE ?', "#{params[:word_part]}%")
        .yield_self do |query|
          if params[:only_solutions] == 'true'
            query.where(is_valid_solution: true)
          else
            query
          end
        end
        .order(word: params[:sort_asc] == 'false' ? :desc : :asc)

      render json: { success: true, words: @wordle_dictionaries }, status: 200
    else
      @wordle_dictionaries = WordleDictionary.order(:word)
      render :index
    end
  end

  def amend_dict
    errors = []
    if !params[:new_words].present? || !params[:update_opt].present? || params[:valid_solutions].nil?
      errors << "Please provide a list of valid words and select an update option"
    else
      new_words = params[:new_words].split("\n").map { |word| 
        { word: word.chomp.strip , is_valid_solution: params[:valid_solutions] }
      }
      delete_opt = params[:update_opt] == "replace"
      errors = update_db(new_words, delete_opt)
    end

    if errors.empty?
      render json: { success: true }, status: 200
    else
      render json: { success: false, errors: errors }, status: 500
    end

  end

  def reset_dict
    new_words = WordleDictionaryBackup.all.map { |record| { word: record.word, is_valid_solution: record.is_valid_solution } }
    errors = update_db(new_words, true)
    if errors.empty?
      render json: { success: true }, status: 200
    else
      render json: { success: false, errors: errors }, status: 500
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def wordle_dictionary_params
      params.require(:wordle_dictionary).permit(:word, :is_valid_solution)
    end

    def update_db(words, delete)
      errors = [] 
      ActiveRecord::Base.transaction do
        begin
          if delete
            WordleDictionary.destroy_all  
          end

          words.each do |word|
            exists = WordleDictionary.find_by(word: word[:word].downcase)
            if exists.nil?
              WordleDictionary.find_or_create_by!(word: word[:word].downcase, is_valid_solution: word[:is_valid_solution])
            else
              exists.is_valid_solution = word[:is_valid_solution]
              exists.save
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          errors << "Failed to update dictionary: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
      return errors
    end

    def check_session_id
      if session[:guest] == true
        redirect_to wordles_play_path and return
      end
  
      all_admins_and_setters = Role.where("role = 'System Admin' OR role = 'Puzzle Setter'")
  
      if all_admins_and_setters.empty?
        redirect_to welcome_path, alert: "You are not authorized to access this page."
      elsif all_admins_and_setters.map(&:user_id).exclude?(session[:user_id])
        redirect_to wordles_play_path
      end
    end
end

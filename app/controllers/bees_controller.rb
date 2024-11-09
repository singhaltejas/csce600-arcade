# Handles redirects of spelling bee
class BeesController < ApplicationController
  # This method shows the seven games from tomorrow
  #
  # @return [Array<Bee>]
  def index
    BeesService.set_week_bee()
    @bees = Bee.where(play_date: Date.tomorrow..Date.tomorrow + 6).order(:play_date)
  end

  # This method sets the bee object to be edited
  #
  # @param [Integer] id the id of bee object to be edited
  # @return [Bee]
  def edit
    @bee = Bee.find(params[:id])
    @valid_words = WordsService.words(@bee.letters)
  end

  # This method updates the bee object
  #
  # @param [Integer] id the id of bee object to be updated
  # @param [Hash] bee_params the updates to be made
  # @return [Bee]
  def update
    @bee = Bee.find(params[:id])

    if @bee.update(bee_params)
      redirect_to edit_bee_path(@bee), notice: "Spelling Bee for #{@bee.play_date.strftime("%B %d")} updated successfully!"
    else
      redirect_to edit_bee_path(@bee), alert: "Invalid update"
    end
  end

  # This method is the starting point of the game
  #
  # @return [nil]
  def play
    session[:sbwords] ||= []
    session[:sbscore] ||= 0
    BeesService.set_day_bee()
    @bee = Bee.find_by(play_date: Date.today)
    @aesthetic = Aesthetic.find_by(game_id: Game.find_by(name: "Spelling Bee").id)

    render "spellingbee"
  end

  # This method is the handler of game logic
  #
  # @param [String] the guessed word
  # @return [nil]
  def submit_guess
    @bee = Bee.find_by(play_date: Date.today)

    BeesService.guess(params[:sbword])

    redirect_to bees_play_path
  end

  private

  def bee_params
    params.require(:bee).permit(:letters)
  end
end

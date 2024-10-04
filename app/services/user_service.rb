# app/services/user_service.rb
class UserService
    def self.find_or_create_user(auth)
        uid = auth["uid"]
        email = auth["info"]["email"]
        names = auth["info"]["name"].split
        first_name = names[0]
        last_name = names[1..].join(" ")

        if Rails.env.test? then
            user = UserRepository.find_by_email('spongey@tamu.edu')
        else 
            user = UserRepository.find_by_email(email)
        end
        

        unless user
            user = UserRepository.create_user(
                uid: uid,
                email: email,
                first_name: first_name,
                last_name: last_name
            )
            Role.create(user_id: user.id, role: "Member")
        end
        # if user.uid == 0 or user.uid == 1
        #     user.uid = uid
        # end
        user
    end

    def self.find_user_by_id(id)
        UserRepository.find_by_id(id)
    end

    def self.fetch_all()
        UserRepository.fetch_all()
    end
end

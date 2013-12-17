module UserFactory

  def self.get_user_by_betaseries_code(code)
    betaseries_user = BetaseriesConnector.get_user(code)

    login = betaseries_user['user']['login']
    betaseries_id = betaseries_user['user']['id']
    user = User.find_by_betaseries_id(betaseries_id)

    if user.nil?
      user = User.new()
      user.betaseries_id = betaseries_id
      user.betaseries_login = login
    end

    user.betaseries_token = betaseries_user['token']
    user.save
    return user
  end

end
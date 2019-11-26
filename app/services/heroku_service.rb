class HerokuService

  def self.call
    heroku = PlatformAPI.connect_oauth('cbe0c157-dd9b-4e2d-931a-169ffc6df0b1')
    app_info = heroku.app.create({})
    p app_info
  end

end

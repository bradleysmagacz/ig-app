module ErrorHelper
  class Error
    def self.internal(message="Something broke")
      render status: 500, json: message
    end

    def self.unprocessable(message="")
      render status: 422, json: message
    end
  end
end

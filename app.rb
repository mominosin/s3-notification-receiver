require 'sinatra'
require 'aws-sdk-core'
require 'logger'


class S3Notif < Sinatra::Base
  set :bind, '0.0.0.0'
  LOGGER = Logger.new('/tmp/s3-notification.log')

  Aws.config = {
     access_key_id: 'xxxxxxxxxxxxxxxxxxxx' ,
     secret_access_key: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  }

  SNS = Aws::SNS::Client.new(region: 'ap-northeast-1')
  post '/s3notification' do
    notif = JSON.parse(request.body.read)
    
    case notif['Type']
    when "SubscriptionConfirmation" then
      SNS.confirm_subscription(:topic_arn => notif['TopicArn'],
                                      :token => notif['Token'],
                                      :authenticate_on_unsubscribe => 'true'
                                     )
    when "UnsubscribeConfirmation" then
      return '200'
    when "Notification" then
      LOGGER.info(notif['Message'])  
    else
      LOGGER.info(notif)  
    end
  end

end
S3Notif.run!

#!/usr/bin/env ruby

require "json"
require "aws-sdk"

AWS_ACCESS_KEY_ID = ENV["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = ENV["AWS_SECRET_ACCESS_KEY"]
AWS_REGION = ENV["AWS_REGION"]
AWS_BUCKET = ENV["AWS_BUCKET"]
LAMBDA_FUNCTION_NAME = ENV["LAMBDA_FUNCTION_NAME"]

Aws.config.update({
  region: AWS_REGION,
  credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
})

s3 = Aws::S3::Client.new
lambda_client  = Aws::Lambda::Client.new

# The next page of results
marker = nil
iteration = 1

loop do
  puts "Iteration: #{iteration}"
  s3_resp = s3.list_objects_v2({
    bucket: AWS_BUCKET,
    prefix: "photos/",
    continuation_token: marker
  }).to_h
  photos = s3_resp[:contents].collect { |k| k[:key] }

  photos.each_with_index do |key, index|
    lambda_resp = lambda_client.invoke({
      function_name: LAMBDA_FUNCTION_NAME,
      invocation_type: "Event", # accepts Event, RequestResponse, DryRun
      log_type: "Tail", # accepts None, Tail
      client_context: "String",
      payload: { Records: [
        { s3: {
          bucket: { name: AWS_BUCKET },
          object: { key: key },
        } }
      ] }.to_json
    })

    puts "[I:#{iteration} #{index+1}/#{photos.count}] #{key}"
  end

  iteration += 1
  # Use next marker or last key for next marker
  marker = s3_resp[:next_continuation_token] || photos.last

  break if !s3_resp[:is_truncated]
end

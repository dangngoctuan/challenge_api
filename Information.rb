# please install gem 'httparty', 'terminal-table' for show output

require 'rubygems'
require 'httparty'
require 'terminal-table'

class General
  include HTTParty
  base_uri 'https://sample-accounts-api.herokuapp.com'

  def initialize(id)
    @id = id
  end

  def get_data_from_api_user
    self.class.get('/users/' + @id.to_s)
  end

  def user
    @user ||= get_data_from_api_user.parsed_response['attributes']
  end
end

class User < General
  def get_data_from_api_accounts
    self.class.get('/users/' + @id.to_s + '/accounts')
  end

  def list_accounts
    @list_accounts ||= get_data_from_api_accounts.parsed_response
  end

  def information_accounts
    list_accounts.each_with_object([]) do |account, array|
      array << [account['attributes']['id'], account['attributes']['name'], account['attributes']['balance']]
    end
  end

  def information_user
    [[user['id'], user['name']]]
  end

  def output_information_user
    puts Terminal::Table.new title: 'Information User', headings: ['ID', 'Name'], rows: information_user
    puts Terminal::Table.new title: 'Information Accounts of User', headings: ['ID', 'Name', 'Balance'], rows: information_accounts
  end
end

def puts_question
  puts 'Please Input Number ID from Keyboard or Enter for exit'
end

def not_found_user
  puts 'Cannot found User with id'
  puts_question
  get_user
end

def get_user
  id = gets.chomp
  if id.to_i > 0
    begin
      new_user = User.new(id)
      new_user.output_information_user
      puts_question
      get_user
    rescue
      not_found_user
    end
  elsif id == ''
    puts 'You were exit'
  else
    not_found_user
  end
end

puts_question
get_user


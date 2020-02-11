require 'sinatra'
require 'sinatra/activerecord'
set :bind, '0.0.0.0'

ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:database => 'wiki.db'
)

class User < ActiveRecord::Base
	validates :username, presence: true, uniqueness: true
	validates :password, presence: true
end

helpers do
	def protected!
		if authorized?
			return
		end
		redirect '/denied'
	end
	
	def authorized?
		if $credentials != nil
			@Userz = User.where(:username => $credentials[0]).to_a.first
			if @Userz
				if @Userz.edit == true
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
end

$myinfo = ""
@info = ""

def readFile(filename)
	info = ""
	file = File.open(filename)
	file.each do |line|
		info = info + line
	end
	file.close
	$myinfo = info
end

get '/' do
	info = "Hello there!"
	len = info.length
	len1 = len
	readFile("wiki.txt")
	@info = info + " " + $myinfo
	len = @info.length
	len2 = len - 1
	len3 = len2 - len1
	@words = len3.to_s
	erb :home
end

get '/about' do
	erb :about
end

get '/create' do
	erb :create
end

get '/edit' do
	info = ""
	file = File.open("wiki.txt")
	file.each do |line|
		info = info + line
	end
	file.close
	@info = info
	erb :edit
end

put '/edit' do
	info = "#{params[:message]}"
	@info = info
	file = File.open("wiki.txt", "w")
	file.puts @info
	file.close
	redirect '/'
end

get '/login' do
	erb :login
end

post '/login' do
	$credentials = [params[:username],params[:password]]
	@Users = User.where(:username => $credentials[0]).to_a.first
	if @Users
		if @Users.password == $credentials[1]
			redirect '/'
		else
			$credentials = ['', '']
			redirect '/wrongaccount'
		end
	else
		$credentials = ['','']
		redirect '/wrongaccount'
	end
end

get '/wrongaccount' do
	erb :wrongaccount
end

get '/createaccount' do
	erb :createaccount
end

post '/createaccount' do 
	n=User.new
	n.username = params[:username]
	n.password = params[:password]
	if n.username == "Admin"
		n.edit = true
	end
	n.save
	redirect "/"
end

get '/logout' do
	$credentials = ['','']
	redirect '/'
end

get '/notfound' do
	erb :notfound
end

get '/noaccount' do
	erb :noaccount
end

get '/denied' do
	erb :denied
end

get '/admincontrols' do
	protected!
	@list2 = User.all.sort_by { |u| [u.id] }
	erb :admincontrols
end

get '/user/:uzer' do
	protected!
	@Userz = User.where(:username => params[:uzer]).to_a.first
	if @Userz != nil
		erb :profile
	else
		redirect '/denied'
	end
end

put '/user/:uzer' do
	n = User.where(:username => params[:uzer]).to_a.first
	n.edit = params[:edit] ? 1 : 0
	n.save
	redirect '/'
end

get '/user/delete/:uzer' do
	protected!
	n = User.where(:username => params[:uzer]).to_a.first
	if n.username == "Admin"
		erb :denied
	else
		n.destroy
		@list2 = User.all.sort_by { |u| [u.id] }
		erb :admincontrols
	end
end

not_found do
	status 404
	redirect '/notfound'
end
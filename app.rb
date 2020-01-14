# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "securerandom"
require "json"

class Memo
  def self.find_by_id(id: memo_id)
    JSON.parse(File.read("model/#{id}.json"), symbolize_names: true)
  end

  def self.create(title: memo_title, body: memo_body)
    hash = { id: SecureRandom.uuid, title: title, body: body }
    File.open("model/#{hash[:id]}.json", "w") { |f| f.puts JSON.pretty_generate(hash) }
  end

  def edit(id: memo_id, title: memo_title, body: memo_body)
    hash = { id: id, title: title, body: body }
    File.open("model/#{hash[:id]}.json", "w") { |f| f.puts JSON.pretty_generate(hash) }
  end

  def destroy(id: memo_id)
    File.delete("model/#{id}.json")
  end
end

helpers do
  def h(str)
    Rack::Utils.escape_html(str)
  end
end

get "/memos" do
  files = Dir.glob("model/*").sort_by { |f| File.mtime(f) }
  @memos = files.map { |file| JSON.parse(File.read(file), symbolize_names: true) }
  erb :memos
end

get "/memos/new" do
  erb :new
end

post "/memos/new" do
  Memo.create(title: params[:title], body: params[:body])
  redirect to("/memos")
end

get "/memos/:id" do
  @memo = Memo.find_by_id(id: params[:id])
  erb :detail
end

get "/memos/edit/:id" do
  @memo = Memo.find_by_id(id: params[:id])
  erb :edit
end

patch "/memos/:id" do
  Memo.new.edit(id: params[:id], title: params[:title], body: params[:body])
  redirect to("/memos/#{params[:id]}")
end

delete "/memos/:id" do
  Memo.new.destroy(id: params[:id])
  redirect to("/memos")
end

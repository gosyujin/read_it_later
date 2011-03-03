require 'uri'
require 'net/http'
# http://rubyforge.org/snippet/detail.php?type=snippet&id=148
require 'simplejsonparser'
# require 'nkf'

# ユーザ情報など読み込み
file = open("init").read.split(",")
USERNAME = file[0]
PASSWORD = file[1]
APIKEY = file[2]

# RIL取得用のURL
url = "https://readitlaterlist.com/v2/get"

hash = {
	# アカウント名とパスワード
	"username" => USERNAME,
	"password" => PASSWORD,
	# apikey
	"apikey" => APIKEY,
}
# format json or xml
hash["format"] = "json"

# パラメータ作成
param = hash.map{|i|i.join("=")}.join("&")

# GETする
uri = URI.parse(url)
proxy_class = Net::HTTP::Proxy(ARGV[0], 8080)
http = proxy_class.new(uri.host)
http.start do |http|
	res = http.get(uri.path + "?#{param}")
	if res.code == "200" then
		json = res.body
		# jsonparseでparseしてもらう
		jsonparse = JsonParser.new.parse(json)
		
		# listのキーを取得
		keys = jsonparse["list"].keys
		for i in 0..keys.length-1
			print_url = jsonparse["list"][keys[i]]["url"]
			print_title = jsonparse["list"][keys[i]]["title"]
			
			# SJIS変換(コマンドプロンプトで見る用)
			# print NKF.nkf('-s', "
			print "#{print_title} ■ #{print_url}\n"
		end
	else
		print "#{res.code}\n"
	end
end

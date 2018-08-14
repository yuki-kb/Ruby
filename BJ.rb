#ルール説明
puts "カジノへようこそ、ここではブラックジャックを行います。最初のチップは1000＄です。"
sleep(1.5)
puts "カットの深さ(カード全体のどこまでをゲームで使うかの程度)は75％で、そのゲーム終了後にデックを新しく用意します。"
sleep(2)
puts "デックを連続して使うためカードカウンティングが可能です。"
sleep(1.5)
puts "サレンダーした際の手札公開は行っておりませんが、プレイヤーがバーストした場合のディーラーの手札公開は行います。"
sleep(2)
puts "また以下のルールは採用していませんので、ご了承ください。"
sleep(1)
puts "スプリット、インシュランス、イーブンマネー、プレミアムルール"
sleep(1)
puts "------------------------------------------------------------------------"

class Common #コンピューター、プレイヤー共通の処理部分

	def calculate_score(cards_size,cards) #手札とその枚数を受け取り,点数を返す。
		score = 0
		num_A = 0
		for i in 0...cards_size
			case cards[i]
			when 2,3,4,5,6,7,8,9,10
				score += cards[i]
			when "A"
				num_A += 1
			when "J","Q","K"
				score += 10
			end
		end
		if num_A > 1
			score += num_A - 1
			if score <= 10
				score += 11
			else
				score += 1
			end
		elsif num_A == 1
			if score <= 10
				score += 11
			else
				score += 1
			end
		end
		return score
	end

end

class Computer < Common#コンピューターの処理

	def decide_first_cards(deck) #デックの一番上と二番目のカードを取り出し、渡す。最初のドロー
		firstCard = deck[0]
		secondCard = deck[1]
		deck.delete_at(0)
		deck.delete_at(0)
		puts "ディーラーの一枚目のカードは#{firstCard}です。"
		return firstCard,secondCard
	end

	def draw(deck) #デックの一番上のカードを取り出し、渡す。
		draw_card = deck[0]
		deck.delete_at(0)
		puts "ディーラーがカードを引きました。"
		return draw_card
	end

	def show_score(cards_size,cards) #手札とその枚数を受け取り、結果を表示する
		puts "ディーラーのカードは#{cards}です。"
		if calculate_score(cards_size,cards) > 21
			puts "ディーラーはバーストです。"
		else
			puts "スコアは#{calculate_score(cards_size,cards)}です。"
		end
	end

end

class Player < Common#プレイヤーの処理

	def decide_first_cards(deck) #デックの一番上と二番目のカードを取り出し、渡す。最初のドロー
		firstCard = deck[0]
		secondCard = deck[1]
		deck.delete_at(0)
		deck.delete_at(0)
		puts "あなたのカードは[#{firstCard},#{secondCard}]です。"
		return firstCard,secondCard
	end

	def draw(deck) #デックの一番上のカードを取り出し、渡す。
		draw_card = deck[0]
		deck.delete_at(0)
		puts "引いたカードは#{draw_card}です。"
		return draw_card
	end

	def show_score(cards_size,cards) #手札とその枚数を受け取り、結果を表示する
		puts "あなたのカードは#{cards}です。"
		if calculate_score(cards_size,cards) > 21
			puts "あなたはバーストです。"
		else
			puts "スコアは#{calculate_score(cards_size,cards)}です。"
		end
	end

end

user_chip = 1000
i = 0
while user_chip > 0
	if i != 0
		puts "デックが75％以上減りました。新しいデックを用意します。"
	end
	#デックを用意する
	deck = []
	for l in 1..4
		deck << "A" << "J" << "Q" << "K"
		for l in 2..10
			deck << l
		end
	end
	deck.shuffle!
	puts "デックをシャッフルしています。"
	sleep(2)
	while deck.size > 13 && user_chip > 0
		i += 1
		puts "第#{i}ゲームを開始します。"
		puts "現在の所持チップは#{user_chip}＄です。いくらベットしますか。"
		while true
			bets = gets.to_i
			if user_chip < bets
				puts "所持チップより多くベットすることはできません。"
			elsif bets > 0
				puts "ベット額は#{bets}です。"
				user_chip -= bets
				break
			else
				puts "正しくベットしてください。"
			end
		end
		#初期設定
		computer_score = 0
		player_score = 0

		#コンピューターの初期手札作成
		com = Computer.new
		computer_cards = com.decide_first_cards(deck)

		#プレイヤーの手札作成
		player = Player.new
		player_cards = player.decide_first_cards(deck)
		#任意の回数カードを引く
		while player.calculate_score(player_cards.size,player_cards) < 21
			puts "------------------------------------------------------------------------"
			puts "以下のアクションを選択して入力してください。各アクションの頭文字３字でも可能です。"
			puts "\"hit\"　　　　　　　 カードをさらに引きます。"
			puts "\"stand\"or\"stay\"　カードを引くのをやめて勝負します。"
			puts "\"double_down\"　　  掛け金を倍にして勝負します。"
			puts "\"surrender\"　　　  降参します。掛け金の半分が返ってきます。"
			print "--->"
			str = gets.chomp
			case str
			when "hit"
				player_cards <<player.draw(deck)
			when "stand","sta","stay"
				puts "勝負します。"
				break
			when "double_down","dou"
				if user_chip < 2*bets
					puts "所持チップが足りません。やり直してください。"
				else
					print "betが倍になりました。"
					user_chip -= bets
					bets *= 2
					puts "現在の掛け金は#{bets}です。"
					player_cards <<player.draw(deck)
				end
			when "surrender","sur"
				puts "降参しました。掛け金の半分の#{bets/2}が返ってきます。"
				user_chip += bets/2
				str == "sur"
				break
			else
				puts "正しく入力しなおしてください。"
			end
		end
		if player.calculate_score(player_cards.size,player_cards) > 21
			puts "バーストしています。お互いの手札公開をします。"
		end
		puts "------------------------------------------------------------------------"
		if str == "sur"
			puts "第#{i}ゲーム終了です。"
			puts "現在のあなたのチップは#{user_chip}＄です。"
			puts "続けてブラックジャックをしますか(yes/no)"
			loop{
				print "->"
				str = gets.chomp
				if str =="yes"
					puts "------------------------------------------------------------------------"
					break
				elsif str =="no"
					puts "------------------------------------------------------------------------"
					break
				else
					puts "正しく入力しなおしてください。"
				end
			}
			if str == "no" || str == "yes"
				next
			end
		end

		#コンピューターの手札作成
		#17を超えるまでディーラーは引かないといけない
		while com.calculate_score(computer_cards.size,computer_cards) < 17
			computer_cards << com.draw(deck)
		end

		#手札のオープン
		sleep(2)
		player.show_score(player_cards.size,player_cards)
		player_score = player.calculate_score(player_cards.size,player_cards)
		sleep(2)
		com.show_score(computer_cards.size,computer_cards)
		computer_score = com.calculate_score(computer_cards.size,computer_cards)
		if player_score == 21 \
			&& player_cards.size == 2
			if computer_score == 21 \
				&& computer_cards.size == 2
				puts "プレイヤー、ディーラーともにブラックジャックです。引き分けです。"
				user_chip += bets
			else
				puts "ブラックジャックで勝ちです。配当が1.5倍になります。"
				user_chip += (2.5*bets).round
			end				 	 
		elsif player_score > 21
			puts "あなたの負けです。"
		elsif computer_score > 21
			puts "あなたの勝ちです。"
			user_chip += 2*bets
		elsif player_score > computer_score
			puts "あなたの勝ちです。"
			user_chip += 2*bets
		elsif computer_score == 21 \
			&& computer_cards.size == 2
			puts "ディーラーがブラックジャックです。あなた負けです。"
		elsif player_score == computer_score
			puts "引き分けです。"
			user_chip += bets
		else
			puts "あなたの負けです。"
		end

		sleep(2)
		puts "第#{i}ゲーム終了です。"
		if user_chip > 0
			puts "現在のあなたのチップは#{user_chip}＄です。"
			puts "続けてブラックジャックをしますか(yes/no)"
			loop{
				print "->"
				str = gets.chomp
				if str =="yes"
					puts "------------------------------------------------------------------------"
					break
				elsif str =="no"
					puts "------------------------------------------------------------------------"
					break
				else
					puts "正しく入力しなおしてください。"
				end
			}
			if str == "no"
				break
			end
		end
	end
	if str == "no"
		break
	end
end

if user_chip > 0
	puts "ゲーム終了です。お疲れさまでした。"
	puts "今回のあなたのチップは#{user_chip}＄です。"
else
	puts "チップがなくなりました。"
end
puts "終了します。"
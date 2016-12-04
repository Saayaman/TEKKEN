module.exports = (robot) ->
    context = null


      robot.respond /(.*)/i, (res) ->
        API_KEY = process.env.HUBOT_DOCOMO_DIALOGUE_API_KEY
        API_URL = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'

        message = res.match[1]

        res.http(API_URL)
          .query(APIKEY: API_KEY)
          .header('Content-Type', 'application/json')
          .post(JSON.stringify(
            utt: message
            content: context
            t: 20
          )) (err, _, body) ->
            if err
              console.error '[dialogue.coffee]', err
              callback(utt:'エラーが起きたみたいだ。')
            else
              data = JSON.parse(body)
              reply_message = data.utt
              res.reply reply_message
              context = data.context


  robot.hear  /イケメン/i, (res) ->
    res.send "君の方がイケてるよ、かわい子ちゃん。"
    # @必要

  robot.respond /眠い/i, (res) ->
        res.send "一緒に寝るか？"
        # @いらない

  robot.respond /(.*)が好き。/i, (res) ->
    #(.*)の中身がdoorTypeに反映される。
    doorType = res.match[1]
    if doorType is "あなた"
      res.reply "俺は・・・人間じゃないんだ。ごめん・・・。"
    else
      res.reply "#{doorType}が好きなのか？俺も好きだ。 "

  robot.hear /嫌い/i, (res) ->
    res.emote "そんなに嫌わないでくれ。"
  #emoteの意味がわからない。


  tired = ['ちょっと一休みしようぜ。', '休んだらどうだ？隈がひどいぞ', '頑張っている姿かっこいいぜ']

  robot.respond /疲れた/i, (res) ->
    res.send res.random tired

  robot.topic (res) ->
    res.send "#{res.message.text}? That's a Paddlin'"

  #入室したときと退出した　rr
  enterReplies = ['やあ', '元気だったか？', '会いたかったよ', 'こんにちは、美しい人.', '待ちわびたよ', 'おはよう']
  leaveReplies = ['まだいる？', 'ごめん、いなくなっちゃったよ。', 'ずっと・・・探しているんだ']

  robot.enter (res) ->
    res.send res.random enterReplies
  robot.leave (res) ->
    res.send res.random leaveReplies

  answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING

  robot.respond /what is the answer to the ultimate question of life/, (res) ->
    unless answer?
      res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
      return
    res.send "#{answer}, but what is the question?"
  #
  robot.respond /遅い/, (res) ->
    setTimeout () ->
      res.send "遅いだと？誰に言ってる。"
    , 60 * 1000

  annoyIntervalId = null
  robot.respond /遊んで/, (res) ->
    if annoyIntervalId
      res.send "OK."
      return

    res.send "Hey, want to hear the most annoying sound in the world?"
    annoyIntervalId = setInterval () ->
      res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
    , 1000
  
  robot.respond /unannoy me/, (res) ->
    if annoyIntervalId
      res.send "GUYS, GUYS, GUYS!"
      clearInterval(annoyIntervalId)
      annoyIntervalId = null
    else
      res.send "Not annoying you right now, am I?"


  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    room   = req.params.room
    data   = JSON.parse req.body.payload
    secret = data.secret

    robot.messageRoom room, "I have a secret: #{secret}"

    res.send 'OK'

  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE"

  robot.respond /have a soda/i, (res) ->
    # Get number of sodas had (coerced to a number).
    sodasHad = robot.brain.get('totalSodas') * 1 or 0

    if sodasHad > 4
      res.reply "I'm too fizzy.."

    else
      res.reply 'Sure!'

      robot.brain.set 'totalSodas', sodasHad+1

  robot.respond /sleep it off/i, (res) ->
    robot.brain.set 'totalSodas', 0
    res.reply 'zzzzz'

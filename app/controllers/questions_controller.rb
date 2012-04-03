# encoding: UTF-8


require 'open-uri'
require 'net/https'
require 'will_paginate/array'
class QuestionsController < ApplicationController
  def cmd
    # a = `sh vntokenizer/vnTokenizer.sh -i input.txt -o output.txt`
    a = `cd vntokenizer/ && sh vnTokenizer.sh -i input.txt -o output.txt`
    puts a
    binding.pry
    redirect_to about_path
  end
  def token
    untoken_questions = Question.where(:token => nil).limit(1000)
    # untoken_questions.each do |question|
    #   question.token = "123456789"
    #   question.save
    # end
    open("vntokenizer/input.txt","w") do |file|
      untoken_questions.each do |question|
        a = question.subject.downcase
        a = a.gsub("@","")
        file << a + "\n"
      end
    end
    a = `cd vntokenizer/ && sh vnTokenizer.sh -i input.txt -o output.txt`
    puts a
    # binding.pry
    edited_archived_questions = []
    open("vntokenizer/output.txt", "r") do |file|
      file.lines.each do |line|
        edited_archived_questions << line.chomp
      end
    end
    untoken_questions.each_with_index do |question,index|
      question.token = edited_archived_questions[index]
      question.save
    end
    redirect_to about_path
  end

  def search
    # question scope
    archived_questions = Question.where("category_id = ?",396545663)
    # get stop_word from file
    stop_word = []
    stopw = File.open("stopword.txt", "r")
    # binding.pry
    stopw.lines.each do |line|
      stop_word << line.chomp
    end
    # get curren question
    user_question = params[:text].downcase
    # write current question to file input.txt to tokenize
    open("vntokenizer/input.txt","w") do |file|
      file << user_question.downcase
    end
    `cd vntokenizer/ && sh vnTokenizer.sh -i input.txt -o output.txt`
    token_question = []
    open("vntokenizer/output.txt", "r") do |file|
      file.lines.each do |line|
        token_question += line.chomp.split
      end
    end
    # retrive key words from google search
    @result = google(user_question)

    # delete stop words
    @result.delete_if {|x| stop_word.include?(x.last)}
    key_words = @result.collect { |x| x.last }

    # get the keys of question

    question_keys = token_question + key_words - stop_word
    # question_keys = token_question - stop_word
    question_keys = question_keys.uniq
    # s.slice!(/[?,!,@,#,$,%,^,&,*,<,.,>,(,)]/)

    @list = []
    archived_questions.each do |question|
      # set_of_words = []
      current_question = question.token.split - stop_word
      set_of_words = question_keys + current_question + key_words - stop_word
      # set_of_words = question_keys + current_question - stop_word
      set_of_words = set_of_words.uniq
      vector1 = []
      set_of_words.each do |w|
        if question_keys.include?(w)
          if @result.rassoc(w)
            vector1 << 2
            # vector1 << 1
          else
            vector1 << 1
          end
        else
          vector1 << 0
        end
      end
      vector2 = []
      set_of_words.each do |w|
        if current_question.include?(w)
          if @result.rassoc(w)
            vector2 << 2
            # vector2 << 1
          else
            vector2 << 1
          end
        else
          vector2 << 0
        end
      end
      # vector1 = set_of_words.map {|x| (question_keys.include?(x)? 1:0)}
      # vector2 = set_of_words.map {|x| (current_question.include?(x)? 1:0)}
      product = product(vector1,vector2)
      cosine_product = cosine_product(vector1,vector2)
      sim_statistic = product/cosine_product
      @list << [question.subject,sim_statistic,set_of_words,vector1,vector2,product,cosine_product]
    end
    @sorted_list = @list.sort{|x,y| y[1] <=> x[1] }
    # binding.pry
  end

  def product(vector1,vector2)
    product = 0
    vector1.each_with_index do |v,index|
      product += v*vector2.at(index)
    end
    return product.to_f
  end

  def normalize_word(words_list)

    words_list.each do |w|
       w.slice!(/[?,!,@,#,$,%,^,&,*,<,.,>,(,)]/)
    end
    return words_list
  end

  def cosine_product(vector1,vector2)
    sum_of_v1 = 0
    sum_of_v2 = 0
    vector1.each do |v|
      sum_of_v1 +=v*v
    end
    vector2.each do |v|
      sum_of_v2 +=v*v
    end
    result = (Math.sqrt(sum_of_v1)*Math.sqrt(sum_of_v2)).to_f
    return result
  end

  def google(text)
    google_api_key = "key=AIzaSyBZPw9NA7hc01QppxpDXm5Pkj8NnJ9Rckg"
    search_result = []
    base_url = "https://www.googleapis.com/customsearch/v1?"
    output_type = "&alt=json"
    query="&q=#{text}"
    customsearch_key = "&cx=000087796417066320718:zdgrva1wm7m"
    #===============================================================================

    [1,11].each do |i|
      url = URI.encode(base_url + google_api_key + customsearch_key + query + output_type + "&start=#{i}")
      buffer = open(url).read
      result = JSON.parse(buffer)
      # xử lý kết quả để tìm tập keyword


      open("vntokenizer/input.txt","w") do |file|
        result["items"].each do |item|
          file << item["title"].downcase + "\n"
        end
      end
      `cd vntokenizer/ && sh vnTokenizer.sh -i input.txt -o output.txt`
      token_question = []
      open("vntokenizer/output.txt", "r") do |file|
        file.lines.each do |line|
          a = line.chomp.split
          a.each do |a|
            if b = search_result.rassoc(a.downcase)
              search_result.delete_at(search_result.index(b))
              search_result.push([b.first+1,b.last.downcase])
            else
              search_result.push([0,a.downcase])
            end
          end
        end
      end
    end

    #===============================================================================
    sorted_result = search_result.sort{ |x,y| y.first <=> x.first }
    # binding.pry
    selected_result = sorted_result.take_while {|i| i.first > 5 }
    return selected_result

    # result["items"].each do |item|
    #   a = item["title"].split
    #   a.each do |a|
    #     if b = search_result.rassoc(a.downcase)
    #       search_result.delete_at(search_result.index(b))
    #       search_result.push([b.first+1,b.last.downcase])
    #     else
    #       search_result.push([0,a.downcase])
    #     end
    #   end
    # end
    # sorted_result = search_result.sort{ |x,y| y.first <=> x.first }
    # selected_result = sorted_result.take_while {|i| i.first > 3 }
    # return selected_result
  end

  def new_category
    @start = Start.new(params[:start])
    @start.save
    redirect_to manage_questions_path
  end

  def manage
    @questions = Question.all
    @numbers = [500,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]
  end

  def update_db
    appid = "appid=dj0yJmk9QTY3anduM0E1SG9MJmQ9WVdrOVZVVjFabk5UTkdjbWNHbzlNelV4TVRZeSZzPWNvbnN1bWVyc2VjcmV0Jng9Y2M-"

    base_url="http://answers.yahooapis.com/AnswersService/V1/getByCategory?"
    format = "&output=json"
    region = "&region=vn"
    result = "&results=50"
    category = "&category_id=" + params["category"]["id"]
    sort = "&sort=date_asc"
    expected_start = params["category"]["start"].to_i

    while Start.where("category_id = ?",params["category"]["id"].to_i).first.start < expected_start do
      @start = Start.where("category_id = ?",params["category"]["id"].to_i).first.start
      start = "&start=" + @start.to_s
      url = URI.encode(base_url+appid+category+start+region+sort+result+format)
      buffer = open(url).read
      result = JSON.parse(buffer)
      result["all"]["questions"].each do |question|
        @question = Question.new
        @question.question_id = question["Id"]
        @question.subject = question["Subject"]
        @question.content = question["Content"]
        @question.date = question["Date"]
        @question.timestamp = question["Timestamp"]
        @question.link = question["Link"]
        @question.qtype = question["Type"]
        @question.category_id = question["CategoryId"]
        @question.category_name = question["CategoryName"]
        @question.user_id = question["UserId"]
        @question.user_nick = question["UserNick"]
        @question.user_photo_url = question["UserPhotoURL"]
        @question.num_answers = question["NumAnswers"]
        @question.num_comments = question["NumComments"]
        @question.chosen_answer = question["ChosenAnswer"]
        @question.chosen_answer_id = question["ChosenAnswererId"]
        @question.chosen_answer_nick = question["ChosenAnswererNick"]
        @question.chosen_answer_timestamp = question["ChosenAnswerTimestamp"]
        @question.chosen_answer_award_timestamp = question["ChosenAnswerAwardTimestamp"]
        if Question.where("question_id = ?",@question.question_id).count == 0
          @question.save
        end # end of if
      end #end of @result["all"]["questions"].each do |question|

      u = Start.where("category_id = ?",params["category"]["id"].to_i).first
      u.start +=result["all"]["questions"].count
      u.save
    end # end of while
    redirect_to manage_questions_path
  end
  # GET /questions
  # GET /questions.json
  def index

    @all = Question.limit(100)
    @categories = Start.all.map { |s| { "name" => s.category_name, :id => s.category_id }}
    # @categories = []
    # @all.each do |q|
    #   if !@categories.include? ({ 'id' => q.category_id, 'name' => q.category_name })
    #     @categories.push ({ 'id' => q.category_id, 'name' => q.category_name })
    #   end
    # end

    if params[:category_id]
      @qs = Question.where(:category_id => params[:category_id])
    else
      @qs = Question.all
    end
    @count = @qs.count
    if @count > 1
      @count = @count.to_s + " questions"
    else
      @count = @count.to_s + " question"
    end

    @questions = @qs.paginate(:page =>params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @questions }
    end
  end

  def show_categories

  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.json
  def new
    @question = Question.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(params[:question])

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "new" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to questions_url }
      format.json { head :ok }
    end
  end


end

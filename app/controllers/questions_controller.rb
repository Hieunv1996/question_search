require 'open-uri'
require 'will_paginate/array'
class QuestionsController < ApplicationController
  def update_db
    appid = "appid=dj0yJmk9QTY3anduM0E1SG9MJmQ9WVdrOVZVVjFabk5UTkdjbWNHbzlNelV4TVRZeSZzPWNvbnN1bWVyc2VjcmV0Jng9Y2M-"
    base_url="http://answers.yahooapis.com/AnswersService/V1/getByCategory?"
    format = "&output=json"
    region = "&region=vn"
    result = "&results=50"
    category = "&category_id=396545664"
    sort = "&sort=date_asc"

    while Start.last.start < 500 do 
      @start = Start.last.start
      start = "&start=" + @start.to_s
      url = URI.encode(base_url+appid+category+start+region+sort+result+format)
      buffer = open(url).read
      @result = JSON.parse(buffer)    
      @result["all"]["questions"].each do |question|
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

      u = Start.last
      u.start +=@result["all"]["questions"].count
      u.save
    end # end of while
    redirect_to root_path
  end
  # GET /questions
  # GET /questions.json
  def index
    @all = Question.all
    @categories = []
    @all.each do |q|
      if !@categories.include? ({ 'id' => q.category_id, 'name' => q.category_name })
        @categories.push ({ 'id' => q.category_id, 'name' => q.category_name })
      end
    end

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

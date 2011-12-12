require 'open-uri'
class QuestionsController < ApplicationController
  def update_db
    appid = "appid=dj0yJmk9QTY3anduM0E1SG9MJmQ9WVdrOVZVVjFabk5UTkdjbWNHbzlNelV4TVRZeSZzPWNvbnN1bWVyc2VjcmV0Jng9Y2M-"
      base_url="http://answers.yahooapis.com/AnswersService/V1/getByCategory?"
      format = "&output=json"
      region = "&region=vn"
      result = "&results=50"
      category = "&category_id=396545663"
      start = "&start=100"
      sort = "&sort=date_asc"
      url = URI.encode(base_url+appid+category+start+region+sort+result+format)
      buffer = open(url).read
      @result = JSON.parse(buffer)
      # binding.pry
      redirect_to root_path
  end
  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @questions }
    end
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

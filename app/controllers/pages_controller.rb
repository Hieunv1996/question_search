class PagesController < ApplicationController
  def update_database

  end
  def home
  end

  def about
    # @u = Question.first.content
    # @v = Question.all[3].content
    @u = "nau thit ca nhu the nao"
    @v = "lam the nao de nau thit ca"
    @u0 = @u.split      
    @v0 = @v.split      
    @gs = @u0 + (@v0-@u0)
    @u1 = @gs.map{ |x| ( @u0.include?(x)? 1:0 ) }
    @v1 = @gs.map{ |x| ( @v0.include?(x)? 1:0 ) }
    @m = []
    @m1 = 0;
    @u1.each_with_index do |n,index|
      @m <<  n*@v1.at(index)
      @m1 += n*@v1.at(index)
    end
    @sum = 0
    @u1.each do |u|
      @sum +=u
    end
    @v1.each do |u|
      @sum +=u
    end
    @sim = @m1.to_f/@sum.to_f

  end

  def help

  end

end




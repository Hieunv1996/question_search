class AddAttributesToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_id, :string
    add_column :questions, :subject, :string
    add_column :questions, :content, :string
    add_column :questions, :date, :string
    add_column :questions, :timestamp, :string
    add_column :questions, :link, :string
    add_column :questions, :type, :string
    add_column :questions, :category_id, :integer
    add_column :questions, :category_name, :string
    add_column :questions, :user_id, :string
    add_column :questions, :user_nick, :string
    add_column :questions, :user_photo_url, :string
    add_column :questions, :num_answers, :integer
    add_column :questions, :num_comments, :integer
    add_column :questions, :chosen_answer, :string
    add_column :questions, :chosen_answer_id, :string
    add_column :questions, :chosen_answer_nick, :string
    add_column :questions, :chosen_answer_timestamp, :string
    add_column :questions, :chosen_answer_award_timestamp, :string
  end
end

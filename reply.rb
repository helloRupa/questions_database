require_relative 'aa_questions'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :id, :question_id, :parent_id, :author_id, :body

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def self.find_by_user_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| Reply.new(datum) }
  end

  def author
    User.find_by_id(@author_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end
  
  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    return nil if data.empty?

    Reply.new(data.first)
  end

  def save
    @id.nil? ? insert : update
  end

  def insert
    update_parent_id

    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_id, @author_id, @body)
      INSERT INTO
        replies (question_id, parent_id, author_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_id, @author_id, @body, @id)
      UPDATE
        replies
      SET
        question_id = ?, parent_id = ?, author_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end

  def update_parent_id
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        MAX(id) AS parent
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    @parent_id = data.empty? ? nil : data.first['parent']
  end
end

require 'pry'

require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    query = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
    SQL
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(query)
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
      SELECT * FROM students
      WHERE name = ?;
    SQL
    student_info_from_db = DB[:conn].execute(query, name)[0]
    self.new_from_db(student_info_from_db)
  end

  def insert
    insertion_query = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(insertion_query, self.name, self.grade)
    get_id_query = <<-SQL
      SELECT id FROM students
      GROUP BY id
      ORDER BY id DESC
      LIMIT 1;
    SQL
    @id = DB[:conn].execute(get_id_query)[0][0]
  end

  def update
    query = <<-SQL
      UPDATE students SET name = ? WHERE id = ?;
    SQL
    DB[:conn].execute(query, self.name, self.id)
  end

  def save
    if !!self.id
      update
    else
      insert
    end
  end

end

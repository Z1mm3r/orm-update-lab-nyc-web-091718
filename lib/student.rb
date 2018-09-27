require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :id,:name,:grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name,grade,id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-sql
      CREATE TABLE students( id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER)
    sql

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-sql
      DROP TABLE students
    sql
    DB[:conn].execute(sql)
  end

  def save

    sql_insert = <<-sql
      INSERT INTO students(name,grade) VALUES (?,?)
    sql

    if(id == nil)

      DB[:conn].execute(sql_insert,@name,@grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

    else
      sql_update = <<-sql
      UPDATE students SET grade = (?), name = (?) where id = (?)
      sql

      DB[:conn].execute(sql_update,@grade,@name,@id)

    end

  end

  def self.create(name,grade)
    student = self.new(name,grade)
    student.save
  end

  def self.new_from_db(row)
    student = self.new(row[1],row[2],row[0])
  end

  def self.find_by_name(name)

    sql = <<-sql
    SELECT * FROM students WHERE name = ? LIMIT 1
    sql
    student = Student.new_from_db(DB[:conn].execute(sql,name).flatten)
  end

  def update ()
    sql_update = <<-sql
    UPDATE students SET grade = (?), name = (?) where id = (?)
    sql

    DB[:conn].execute(sql_update,@grade,@name,@id)
  end

end

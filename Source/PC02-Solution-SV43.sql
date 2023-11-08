create database Repaso_PC02_2
use Repaso_PC02_2


--Pregunta 1)
CREATE TABLE Estudiante (
       codigo nvarchar(3) not null,
     nombre nvarchar(10) not null,
     apellido_paterno nvarchar(15) not null,
     apellido_materno nvarchar(15) not null,
     fecha_nacimiento date,
     direccion nvarchar(40) not null,
     categoria nvarchar(20)
     constraint PKEstudiante primary key(codigo)
)

CREATE TABLE Cursos (
    codigo int identity(1,1),
  nombre nvarchar(25) not null,
  vacantes int,
  matriculados int,
  profesor nvarchar(50) not null,
  costo money not null,
  creditos int not null
  constraint PKCurso primary key(codigo)
)

CREATE TABLE Matricula (
     codigo int identity(1,1),
   codigo_estudiante  nvarchar(3),
   codigo_curso int,
   horas int not null,
   fecha_reserva date,
   fecha_matricula date,
   mensualidad money not null,
   control_proceso nvarchar(15)
   constraint PKMatricula primary key (codigo),
   constraint FKEstudiante foreign key (codigo_estudiante) References Estudiante (codigo), 
   constraint FKCurso foreign key (codigo_curso) References Cursos (codigo)
)

CREATE TABLE Auditoria (
     codigo int identity(1,1),
     fecha_registro date,
   codigo_matricula int,
   descripcion nvarchar(50),
   usuario nvarchar(50)
   constraint PKAuditoria primary key (codigo)

)

--Pregunta 2) 

INSERT INTO Estudiante ( codigo ,nombre , apellido_paterno ,apellido_materno,fecha_nacimiento ,direccion ,categoria) VALUES (
         'MJD', 'Mathias','Jave','Diaz', '2004-11-27', 'San Isidro', 'Tercio Superior'), 
     ('GHP', 'Gustavo','Huilca','Chipana', '2004-09-27', 'Lince', 'Quinto Superior'),
      ('AME', 'Armando','Mansilla','Espinoza', '2001-04-13', 'Lince', 'Tercerio Superior'),
       ('SRH', 'Sebastian','Ramirez','Hoffman', '2003-03-15', 'Jesus Maria', 'Quinto Superior'),
       ('AVA', 'Alex','Vasquez','Avila', '2005-02-20', 'Jesus Maria', 'Quinto Superior'),
       ('NEG', 'Norman','Eyzaquirre','Gomez', '2004-09-12', 'Miraflores', 'Tercio Superior'),
       ('CLC', 'Clara','Lopez','Castillana', '2003-05-10', 'San Isidro', 'Quinto Superior'),
       ('MJO', 'Mario','Jobando','Oviedo', '2002-08-05', 'Surco', 'Tercio Superior'),
       ('ISC', 'Iam','Sanchez','Carrillo', '2003-09-20', 'La Molina', 'Tercio Superior'),
       ('AQP', 'Andres','Qamanes','Portocarrillo', '2002-03-15', 'Surco', 'Quinto Superior')

INSERT INTO Cursos (nombre,vacantes ,matriculados , profesor ,costo,creditos )VALUES  
 ('Math', 12, 10, 'Juan Padilla', 500, 3),
 ('Quimica', 20, 5, 'Francisco Montoya', 400, 5),
 ('Fisica', 30, 15, 'Luis Reyes', 700, 6),
 ('Computo', 30, 25, 'Walter Cueva', 2000, 6),
 ('Disenio', 40, 10, 'Juan Moroco', 1000, 4),
 ('Filosofia', 20, 15, 'Marcelo Poggi', 600, 2),
 ('Algebra', 30, 19, 'Jesus Acosta', 500, 4),
 ('Macro', 40, 25, 'Gianpul Bernardi', 800, 4),
 ('Geometria', 30, 0,  'Daniella Vargas', 400, 3),
 ('Trigonometria', 30, 23, 'Fidel Garcia', 500, 3)


 --Pregunta 3) 

 go
 Create procedure USPInsertMatricula  
   @codigo_estudiante nvarchar(3),
   @codigo_curso int,
   @fecha_reserva date = getDate,
   @fecha_matricula date = NULL,
   @mensualidad money,
   @control_proceso nvarchar(15) = 'Reservado'
as
  begin --Inicio del procedimiento almacenado
     begin try --Inicio de busqueda de exepciones 
    begin transaction --Inicio de transaccion
       INSERT INTO Matricula(codigo_estudiante, codigo_curso, fecha_reserva, fecha_matricula, mensualidad, control_proceso) 
     Values (@codigo_estudiante, @codigo_curso, @fecha_reserva, @fecha_matricula, @mensualidad, @control_proceso)
     print('Datos insertados en la matricula')
    commit transaction --Confirma una transaccion exitosa
   end try --Fin de busqueda de execpciones
   begin catch --Captura de excepcion
        print error_message()
      rollback transaction --Retorna a la transaccion
    end catch --Termina la execpcion
  end --Fin del procedimiento almacenado

--Pregunta 4)
CREATE Procedure USPUpdateProcedureControlandDate 
     @codigo_matricula int,
   @control_proceso nvarchar(15) = 'Matriculado'
as
begin
   select * from Matricula
   where codigo = @codigo_matricula and control_proceso ='Reservado'
    begin try
    begin transaction
        update Matricula
      set control_proceso = @control_proceso, fecha_matricula = GETDATE()
       WHERE codigo = @codigo_matricula and control_proceso ='Reservado'
    commit transaction
  end try
   begin catch --Captura de excepcion
        print error_message()
      rollback transaction
    end catch --Termina la execpcion
end


--Pregunta 5)
go
CREATE TRIGGER TRUpdateandInsert on Matricula --Indicar la base de datos donde se capturara el trigger 
   for insert,update
   AS
   begin
      if exists (select * from inserted)
    begin
      if exists (select * from deleted)
      begin 
        insert into Auditoria(codigo_matricula, descripcion, fecha_registro, usuario)
      select codigo, 'Matricula Actualizada', getdate(), SUSER_NAME() from inserted
    end
    else 
      begin
         insert into Auditoria (codigo_matricula, descripcion, fecha_registro, usuario)
             select codigo, 'Matricula Reservada', getdate(), SUSER_NAME() from inserted
      end
    end
   end

--Pregunta 6)
CREATE FUNCTION FNTotalStudentsByCategory(@category nvarchar(20))
RETURNS INT
begin
   declare @TotalStudents int 
   set @TotalStudents = (SELECT COUNT(codigo) FROM Estudiante where categoria = @category)
   RETURN @TotalStudents
end

print dbo.FNTotalStudentsByCategory('Quinto Superior')



--Pregunta 7)

CREATE FUNCTION FNSpaceAvaibleByCourse(@id int)
RETURNS INT 
  begin 
    declare @spaces int 
  set @spaces = (SELECT vacantes-matriculados  FROM Cursos Where codigo = @id)
  RETURN @spaces
  end

  print dbo.FNSpaceAvaibleByCourse(4)
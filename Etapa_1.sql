--ETAPA 1
-- Trabalho Realizado por a22005012

--E1.1
create table SongDump(
        text varchar(2000)
);



LOAD DATA INFILE '/var/lib/mysql-files/songs.txt' INTO TABLE DumpSong;

SELECT *
from DumpSong;

---------------------------------------------------------------------

create table DetailsSongDump(
        text varchar(2000)
);


LOAD DATA INFILE '/var/lib/mysql-files/song_details.txt' INTO TABLE DetailsSongDump;

SELECT *
from DetailsSongDump;

----------------------------------------------------------------------

create table ArtistsDump(
        text varchar(2000)
);

LOAD DATA INFILE '/var/lib/mysql-files/song_artists.txt' INTO TABLE ArtistsDump;

SELECT *
from ArtistsDump;


--E1.3 
-- utilizar tabelas temporarias para limpar os dados

--tratamento de Song
create table SongDump(
        text varchar(2000)
);

//quantas linhas é que temos: 174354
SELECT *
from DumpSong;

//criar tabela com o split ja feito e adicionar segundo condições
create table SongDumpSplited(
        id varchar(2000),
        title varchar(2000),
        launch_date varchar(2000)
);

SELECT SUBSTRING_INDEX(text,'@', -1)
        FROM DumpSong

INSERT INTO SongDumpSplited (id, title, launch_date)
        SELECT 
        SUBSTRING_INDEX(text,'@', 1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 2), '@', -1),
        SUBSTRING_INDEX(text,'@', -1)
        FROM DumpSong;
               
SELECT *
from SongDumpSplited;

--conditions------------------

create table SongDirty(
        id varchar(2000),
        title varchar(2000),
        launch_date varchar(2000)
);

INSERT INTO SongDirty (id, title, launch_date)
SELECT 
        trim(id),
        trim(title),
        trim(launch_date)
from SongDumpSplited
-- 174354

--general conditions
delete from SongDirty 
where 
        CHAR_LENGTH (launch_date) <= 3
        OR CHAR_LENGTH (id) <= 0
        OR CHAR_LENGTH (title) <= 0  
        OR CHAR_LENGTH (launch_date) >= 6 
        OR id = title
        OR id = launch_date
        OR title = id
        OR title = launch_date
        or launch_date = id
        or launch_date = title
 
 -- deleted 191
 
 -- E1.4.1
-- songs with repeated ids 1890       
SELECT id
from SongDirty
GROUP BY id
HAVING COUNT(id) > 1;

select * from SongDirty
-- 174163

-- E1.4.2
delete SongDirty.* from SongDirty
INNER JOIN
(
select id
        from SongDirty
        GROUP BY id
        HAVING COUNT(id) > 1) as x on x.id = SongDirty.id
-- deleted 4045 lines

select * from SongDirty
-- 170118

----------------------------------------------------------------------------

create table Song(
        id varchar(200) PRIMARY KEY,
        title varchar(2000),
        launch_date int
);

insert into Song
select id, title, launch_date
from SongDirty;

--agora para song details

//quantas linhas é que temos: 174354
SELECT *
from DetailsSongDump;


//criar tabela com o split ja feito e adicionar segundo condições
create table DetailsSongDumpSplited(
        id varchar(2000),
        duracao varchar(2000),
        letra_explicita varchar(2000),
        popularidade varchar(2000),
        grau_dancabilidade varchar(2000),
        grau_vivacidade varchar(2000),
        volume_som_medio varchar(2000)
);


SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 7), '@', -1)
        FROM DetailsSongDump

INSERT INTO DetailsSongDumpSplited (id, duracao, letra_explicita, popularidade, grau_dancabilidade, grau_vivacidade, volume_som_medio)
        SELECT 
        trim(SUBSTRING_INDEX(text,'@', 1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 2), '@', -1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 3), '@', -1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 4), '@', -1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 5), '@', -1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 6), '@', -1)),
        trim(SUBSTRING_INDEX(SUBSTRING_INDEX(text,'@', 7), '@', -1))
        FROM DetailsSongDump;
               
SELECT *
from DetailsSongDumpSplited;

--conditions--------------------------------------------------------------------------

create table DetailsSongDirty(
        id varchar(2000),
        duracao varchar(2000),
        letra_explicita varchar(2000),
        popularidade varchar(2000),
        grau_dancabilidade varchar(2000),
        grau_vivacidade varchar(2000),
        volume_som_medio varchar(2000)
);

INSERT INTO DetailsSongDirty (id, duracao, letra_explicita, popularidade, grau_dancabilidade, grau_vivacidade, volume_som_medio)
SELECT 
        (id),
        (duracao),
        (letra_explicita),
        (popularidade),
        (grau_dancabilidade),
        (grau_vivacidade),
        (volume_som_medio)    
from DetailsSongDumpSplited;
-- 174354

--general conditions
delete from DetailsSongDirty 
where 
        CHAR_LENGTH (id) <= 0
        OR CHAR_LENGTH (duracao) <= 0
        OR CHAR_LENGTH (letra_explicita) <= 0
        OR CHAR_LENGTH (popularidade) <= 0
        OR CHAR_LENGTH (grau_dancabilidade) <= 0
        OR CHAR_LENGTH (grau_vivacidade) <= 0
        OR CHAR_LENGTH (volume_som_medio) <= 0
        
 -- deleted 3437
 
 -- E1.4.1
-- songs with repeated ids 1817       
SELECT id
from DetailsSongDirty
GROUP BY id
HAVING COUNT(id) > 1;

select * from DetailsSongDirty
-- 170917
-- E1.4.2
delete DetailsSongDirty.* from DetailsSongDirty
INNER JOIN
(
select id
        from DetailsSongDirty
        GROUP BY id
        HAVING COUNT(id) > 1) as x on x.id = DetailsSongDirty.id
-- deleted 3889 lines

select * from DetailsSongDirty
-- 167028

----------------------------------------------------------------------------

create table DetailsSong(
        id varchar(2000),
        duracao int(4),
        letra_explicita int(4),
        popularidade int(3),
        grau_dancabilidade double,
        grau_vivacidade double,
        volume_som_medio double
);

insert into DetailsSong
select id, duracao, letra_explicita, popularidade, grau_dancabilidade, grau_vivacidade, volume_som_medio
from DetailsSongDirty;

--agora para artists

//quantas linhas é que temos: 165627
SELECT *
from ArtistsDump;


//criar tabela com o split ja feito e adicionar segundo condições
create table ArtistsDumpSplited(
        id varchar(2000),
        artists varchar(2000)
);


SELECT SUBSTRING_INDEX(text,'@', -1)
        FROM ArtistsDump

INSERT INTO ArtistsDumpSplited (id, artists)
        SELECT 
        SUBSTRING_INDEX(text,'@', 1),
        SUBSTRING_INDEX(text,'@', -1)
        FROM ArtistsDump;
               
SELECT *
from ArtistsDumpSplited;

--conditions--------------------------------------------------------------------------

create table ArtistsDirty(
        id varchar(2000),
        artists varchar(2000)
);

INSERT INTO ArtistsDirty (id, artists)
SELECT 
        trim(id),
        trim(artists)        
from ArtistsDumpSplited
-- 165627

--general conditions
delete from ArtistsDirty 
where 
        CHAR_LENGTH (id) <= 0
        OR CHAR_LENGTH (artists) <= 0  
        OR id = artists
 
 -- deleted 0
 
-- E1.4.1
-- artists with repeated ids 1731  
SELECT id
from ArtistsDirty
GROUP BY id
HAVING COUNT(id) > 1;

select * from ArtistsDirty
-- 165627

--E1.4.2
delete ArtistsDirty.* from ArtistsDirty
INNER JOIN
(
select id
        from ArtistsDirty
        GROUP BY id
        HAVING COUNT(id) > 1) as x on x.id = ArtistsDirty.id
-- deleted 3698 lines

select * from ArtistsDirty
-- 161929

----------------------------------------------------------------------------

create table Artists(
        id varchar(200) PRIMARY KEY,
        Artists varchar(2000)
);

insert into Artists
select id, artists
from ArtistsDirty;

-- after cleans E1.3.1 E1.3.2 E1.3.3

-- deal with quotes
update Artists
set artists = replace(replace(artists, ']"', ''), '"[', '')
where
        substring(artists, 1, 1) = '"'
        and substring(artists, -1, 1) = '"'  

-- deal with square brackets       
update Artists
set artists = replace(replace(artists, ']', ''), '[', '')
where
        substring(artists, 1, 1) = '['
        and substring(artists, -1, 1) = ']'  
        
        
-- deal with double quotes ""
select *
from Artists 
where LOCATE('""', artists) > 0;  

-- tornar grupos de artistas em artistas singulares
create table ArtistsSolo(
        artista_id int(10) not null AUTO_INCREMENT PRIMARY KEY, 
        id varchar(2000),
        Artists varchar(2000)
);

create function amount_of_commas(string varchar(2000))
returns int(10) deterministic
return CHAR_LENGTH(string) - CHAR_LENGTH( REPLACE ( string, ',', '') );

@delimiter %%%;
CREATE PROCEDURE procedure_load_song_artists()
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
        declare x INT default 0;
        SET x = 0;
        
        WHILE x <= 28 DO
               
                insert into ArtistsSolo(id, Artists)
                select id, trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists,',', x + 1), ',', -1))
                from Artists
                where 
                        amount_of_commas(artists) >= x and amount_of_commas(trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists,',', x + 1), ',', -1))) = 0;
                     
                set x = x + 1;
         end while;
END;
%%%
@delimiter ; 
%%%

call procedure_load_song_artists()

--E1.3.4
-- o numero de virgulas indica o numero de artistas
select amount_of_commas(artists) + 1, artists
from Artists
order by amount_of_commas(artists) + 1 DESC


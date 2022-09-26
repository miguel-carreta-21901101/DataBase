--Etapa2

--E2.5.1
SELECT * from DetailsSong 
where
        DetailsSong.id NOT IN(select Song.id from Song);
-- 256 song songdetails que não tem match de id em Song

-- 256 song songdetails deleted
delete DetailsSong.* from DetailsSong 
where
        DetailsSong.id NOT IN(select Song.id from Song);
        
--E2.5.2
-- foi feito na Etapa2.7        

--E2.5.3
create table load_song_artists(
        musica_id varchar(24),
        artists varchar(600),
        artista_id int(10)
);
--ArtistsSolo tem um index(artista_id)
--então basta fazer esse index * 100
--no entanto outra opção era um procedure de insert

--set @x = 0;
--CREATE TRIGGER trigger_insert_load_song_artists before INSERT
--ON load_song_artists
--FOR EACH ROW
--	       @x = @x + 100,
--	       new.artista_id =  @x;

insert into load_song_artists(musica_id, artists, artista_id)
        select
                id,
                artists,
                artista_id * 100
                from ArtistsSolo;
                
--E2.5.4
--função que retorna a posição do artista relativamente a um grupo de artistas(string
@delimiter %%%;
CREATE FUNCTION pos_artist(artist varchar(600), string varchar(2000))
RETURNS int(10) deterministic

BEGIN

   DECLARE current_str varchar(2000);
   DECLARE pos int(10);
   
   set current_str = string;
   set pos = 1;

   label:
   while POSITION(artist in current_str) != 1 DO
      set current_str = substring(current_str, 2);
        if STRCMP(LEFT(current_str, 1), ",") = 0 then
                set pos = pos + 1;
        END IF;
      END
   while label;
   RETURN pos;

END;%%%
@delimiter ; 
%%%
-- load_song_artists já tem os artistas singulares e com o incremento de 100 no index
-- o uptade serve para atualizar a parte mais à direita desse index de modo a saber a "pos" do artista
-- relativamente a certa musica
update load_song_artists
inner join Artists grupo_artistas on grupo_artistas.id = load_song_artists.musica_id
set artista_id = artista_id + pos_artist(load_song_artists.artists, grupo_artistas.Artists)

--E2.5.5
-- query 
select load_song_artists.artista_id, load_song_artists.musica_id
from load_song_artists
left join artista
on load_song_artists.artists = artista.nome_artistico
ORDER by load_song_artists.musica_id, RIGHT(load_song_artists.artista_id, 2)

--E2.6

create table load_song(
musica_id varchar(24),
titulo varchar(200),
ano int(4))

create table load_song_detail(
musica_id varchar(24),
duracao int(10),
letra_explicita tinyint(4),
popularidade int(3),
grau_dancabilidade float,
grau_vivacidade float,
volume_medio float)

-- load_song_artists já tinha sido feito

create table tipo_contribuicao(
id varchar(6) PRIMARY KEY,
descricao varchar(100))

create table musica_relacionada(
musica_id1 varchar(24),
FOREIGN KEY(musica_id1) REFERENCES musica(id),
musica_id2 varchar(24),
FOREIGN KEY(musica_id2) REFERENCES musica(id),
descricao varchar(10000))

create table musica(
id varchar(22) PRIMARY KEY,
titulo varchar(200),
ano int(4),
duracao int(10),
letra_explicita tinyint(4),
popularidade int(3),
grau_dancabilidade double,
grau_vivacidade double,
volume_medio double)

create table artista(
id int(10) unsigned PRIMARY KEY,
nome_artistico varchar(200),
nome_real varchar(20),
data_nascimento int(11),
biografia varchar(10000))

create table contribuicao_artista(
artista_id int(10) unsigned,
musica_id varchar(22),
tipo_contribuicao_id varchar(6),
FOREIGN KEY(artista_id)  REFERENCES artista(id),
FOREIGN KEY(musica_id) REFERENCES musica(id),
FOREIGN KEY(tipo_contribuicao_id) REFERENCES tipo_contribuicao(id),
descricao varchar(10000))

create table rotulo_artista(
artista_id int(10) unsigned,
FOREIGN KEY(artista_id) REFERENCES artista(id),
rotulo_id varchar(6),
FOREIGN KEY(rotulo_id) REFERENCES rotulo(id))

create table rotulo(
id varchar(6) PRIMARY KEY,
descricao varchar(200))

create table rotulo_musica(
musica_id varchar(22),
FOREIGN KEY(musica_id) REFERENCES musica(id),
rotulo_id varchar(6),
FOREIGN KEY(rotulo_id) REFERENCES rotulo(id))

create table faixa(
musica_id varchar(22),
FOREIGN KEY(musica_id) REFERENCES musica(id),
album_id int(10) unsigned,
FOREIGN KEY(album_id) REFERENCES album(id),
posicao int(3),
descricao varchar(10000))

create table album(
id int(10) unsigned PRIMARY KEY,
nome varchar(200),
data_lancamento int(4))

--E2.7
-- inserir dados na tabela load_song_detail

insert into load_song_detail
select *
from DetailsSong

-- inserir dados na tabela load_song
-- exestia ainda titulos grandes demais para varchar(200) em title

insert into load_song
select *
from Song
where CHAR_LENGTH(title) <= 200

-- usar o left porque queremos todas as songs, e caso exista um detail para essa song atribuir, caso não a song existe mas sem details
insert into musica(id, titulo, ano, duracao, letra_explicita, popularidade, grau_dancabilidade, grau_vivacidade, volume_medio)
select load_song.musica_id,
        load_song.titulo,
        load_song.ano,
        load_song_detail.duracao,
        load_song_detail.letra_explicita,
        load_song_detail.popularidade,
        load_song_detail.grau_dancabilidade,
        load_song_detail.grau_vivacidade,
        load_song_detail.volume_medio
        from load_song
                left join load_song_detail on load_song.musica_id = load_song_detail.musica_id
                
--E2.8
-- ainda exestia alguns artists com o nome demasiado comprido , artists varchar(600) nome_artistico varchar(200)
-- tentei usar o last_insert_id 
insert into artista(id, nome_artistico, nome_real, data_nascimento, biografia)
select load_song_artists.artista_id,
        load_song_artists.artists,
        null,
        null,
        null
        from load_song_artists
        where LAST_INSERT_ID(artista_id + 1) and CHAR_LENGTH(artists) <= 200
 
-- ainda exestia alguns artists com o nome demasiado comprido , artists varchar(600) nome_artistico varchar(200), são estes:     
select *
from load_song_artists
where artists not in( select nome_artistico from artista)

--E2.9
insert into album
values(1, "our time", 2001);

insert into album
values(2, "magic", 2002);

insert into album
values(3, "light", 2003);

insert into album
values(4, "river", 2004);

insert into album
values(5, "waiting", 2005);

select *
from musica

-- primeiro album
insert into faixa
values("000G1xMMuwxNHmwVsBdtj1", 1, 1, "opening");

insert into faixa
values("000jBcNljWTnyjB4YO7ojf", 1, 2, "core");

insert into faixa
values("000mGrJNc2GAgQdMESdgEc", 1, 3, "main");

insert into faixa
values("000Npgk5e2SgwGaIsN3ztv", 1, 4, "bonus");

insert into faixa
values("000py0jh5yT85aczhQ9QQQ", 1, 5, "bonus");

-- segundo album
insert into faixa
values("000u1dTg7y1XCDXi80hbBX", 2, 1, "opening");

insert into faixa
values("000x2qE0ZI3hodeVrnJK8A", 2, 2, "core");

insert into faixa
values("000ZxLGm7jDlWCHtcXSeBe", 2, 3, "main");

insert into faixa
values("0012iPKNQl1zhdYwq3iVa1", 2, 4, "bonus");

insert into faixa
values("00147h65HDYSncB3byziPP", 2, 5, "bonus");

-- terceiro album
insert into faixa
values("001ZmOPuWEW5czwun7nkha", 3, 1, "opening");

insert into faixa
values("0024tEymsoc9FyKUauQngQ", 3, 2, "core");

insert into faixa
values("0025JMWRhsWx0GXdlzhHMO", 3, 3, "main");

insert into faixa
values("002aR3zqP6SvscCnPT44on", 3, 4, "bonus");

insert into faixa
values("002CcxKpBE1tfKOy2CRaWr", 3, 5, "bonus");

-- quarto album
insert into faixa
values("002dh6a4LfxfGGnhPZY4fG", 4, 1, "opening");

insert into faixa
values("002sGwDZYna3CKXbYIilHz", 4, 2, "core");

insert into faixa
values("003d3VbyJTZiiOYT2W7fnQ", 4, 3, "main");

insert into faixa
values("003FTlCpBTM4eSqYSWPv4H", 4, 4, "bonus");

insert into faixa
values("003IdD0Ir5LSZHlrPpLZlm", 4, 5, "bonus");

-- quinto album
insert into faixa
values("003JzPprzThp8SHUctgXnn", 5, 1, "opening");

insert into faixa
values("003vvx7Niy0yvhvHt4a68B", 5, 2, "core");

insert into faixa
values("003WuNd8vTwCW4JyhFQMYT", 5, 3, "main");

insert into faixa
values("0046quUYhSAFccrKIC3Iht", 5, 4, "bonus");

insert into faixa
values("004cCP7Csq7U0m67DDzEFs", 5, 5, "bonus");

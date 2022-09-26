--Etapa3
--E3.10
-- query que indica os artistas com o nome_artisitico duplicado
select artista.nome_artistico, COUNT(artista.nome_artistico)
from artista
GROUP BY artista.nome_artistico
HAVING COUNT(artista.nome_artistico) > 1;

--delete      
delete artista.* from artista
INNER JOIN
(
select nome_artistico
        from artista
        GROUP BY nome_artistico
        HAVING COUNT(nome_artistico) > 1) as x on x.nome_artistico = artista.nome_artistico;
--deleted 203.526 lines


--E3.11
-- query que indica os load_song_artists que têm musica_id que não existe na tabela musica
select *
from load_song_artists
where not exists(
        select *
        from musica
        where musica.id = load_song_artists.musica_id)

--delete      
delete load_song_artists.* 
from load_song_artists
where not exists(
        select musica.id
        from musica
        where musica.id = load_song_artists.musica_id)

--deleted 476 lines

--E3.12
-- query 
select load_song_artists.musica_id, load_song_artists.artista_id
from load_song_artists
left join artista
on load_song_artists.artists = artista.nome_artistico
ORDER by load_song_artists.musica_id, RIGHT(load_song_artists.artista_id, 2)

--E3.13
-- o tipo_contribuicao_id é uma key como não tinhamos adicionado nada ainda vamos fazer agora
insert into tipo_contribuicao values("Empty", "No description")

-- existem artistas que existem em load_song_artists mas nao em artista
-- devido ao delet de nomes duplicados
-- fazer condicao

INSERT INTO contribuicao_artista
select load_song_artists.artista_id, load_song_artists.musica_id, "Empty", "No description"
from load_song_artists
left join artista
on load_song_artists.artists = artista.nome_artistico
where artista_id in (select id from artista)
ORDER by load_song_artists.musica_id, RIGHT(load_song_artists.artista_id, 2)



-- E3.14.1.Recebendo um ano, contar o número de canções editadas nesse ano;
SET @ano := 2021;
select count(*)
from musica
where ano = @ano

-- E3.14.2.Contar o número de musicas editadas por cada ano;
 
SELECT ano, COUNT(*)
FROM musica
GROUP BY ano
ORDER BY COUNT(*) DESC;

--E3.14.3.Contar o número de músicas com o mesmo titulo;
select count(*)
from(
        select titulo, count(titulo)
        from musica
        group by titulo
        having count(titulo) > 1) as x
        
-- E3.14.4.Adicionar uma coluna na tabela musica para guardar a duração em Minuto:segundo

--E3.14.5
insert into rotulo
values(1, "Metal");
insert into rotulo
values(2, "Pop");
insert into rotulo
values(3, "Hip-Hop");
insert into rotulo
values(4, "Techno");
insert into rotulo
values(5, "Rap");
--associar rotulos a artistas
select *
from artista
insert into rotulo_artista
values(3701, 1);
insert into rotulo_artista
values(3701, 2);
insert into rotulo_artista
values(3701, 3);
insert into rotulo_artista
values(3701, 4);
insert into rotulo_artista
values(3701, 5);

insert into rotulo_artista
values(9001, 1);
insert into rotulo_artista
values(9001, 2);

insert into rotulo_artista
values(11301, 2);
insert into rotulo_artista
values(11301, 3);
insert into rotulo_artista
values(11301, 4);

insert into rotulo_artista
values(11901, 2);

insert into rotulo_artista
values(13201, 1);
insert into rotulo_artista
values(13201, 2);

insert into rotulo_artista
values(16601, 1);
insert into rotulo_artista
values(16601, 2);
insert into rotulo_artista
values(16601, 3);
insert into rotulo_artista
values(16601, 4);

insert into rotulo_artista
values(22601, 2);
insert into rotulo_artista
values(22601, 3);
insert into rotulo_artista
values(22601, 4);

insert into rotulo_artista
values(18601, 1);
insert into rotulo_artista
values(18601, 2);
insert into rotulo_artista
values(18601, 3);

--E3.14.6
select
        sum(if(rotulo_id = 1, 1,0))as metal,
        sum(if(rotulo_id = 2, 1,0))as pop,
        sum(if(rotulo_id = 3, 1,0))as hiphop,
        sum(if(rotulo_id = 4, 1,0))as techno,
        sum(if(rotulo_id = 5, 1,0))as rap
from rotulo_artista


--E3.14.7.Dado um inteiro N, e os anos X e Y, escrever um query que retorna as N músicas
--mais dançáveis entre os anos X e Y (inclusive);

-- limit define o numero de resuldados a mostar
SET @ano_menor := 2000;
SET @ano_maior := 2021;
select titulo, grau_dancabilidade
from musica
where musica.ano >= @ano_menor  and musica.ano <= @ano_maior
order by grau_dancabilidade desc limit 10

--E3.14.8.Retorna todos os artistas que num dado período apenas lançaram uma música,
--ordenados alfabeticamente pelo nome do artista

SET @ano := 2021;
select *
from artista inner join(
        select distinct artista_id
        from contribuicao_artista
        inner join musica
        on contribuicao_artista.musica_id = musica.id
        where musica.ano = @ano)as x
on x.artista_id = artista.id
order by artista.nome_artistico

--E3.14.9
-- o artista que tem mais temas -> tem 5 temas
SET @temas_menor:= 1;
SET @temas_maior := 4;
select artista_id, count(artista_id)
from rotulo_artista
group by artista_id
having count(artista_id) > @temas_menor and count(artista_id) < @temas_maior
order by count(artista_id) DESC

--E3.14.10
SET @ano_menor := 2000;
SET @ano_maior := 2021;
select descricao
from rotulo inner join(
select rotulo_id
from rotulo_artista inner join(
        select artista_id
        from artista
        inner join(
                select contribuicao_artista.artista_id, ano
                from musica
                inner join contribuicao_artista
                on contribuicao_artista.musica_id = musica.id
                where musica.ano >= @ano_menor and musica.ano <= @ano_maior) as x
                on x.artista_id = artista.id) as y
        on rotulo_artista.artista_id = y.artista_id
        )as z
        on id = z.rotulo_id

--E3.14.11
SET @ano_menor := 2000;
SET @ano_maior := 2021;
select nome_artistico, ano
from artista
inner join(
        select contribuicao_artista.artista_id, ano
        from musica
        inner join contribuicao_artista
        on contribuicao_artista.musica_id = musica.id
        where musica.ano > @ano_menor and musica.ano < @ano_maior) as x
        on x.artista_id = artista.id
        
--E3.14.12
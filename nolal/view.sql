
create or replace view nolstedt as (
select c.id,
cc.gender_c as gender_c,
t.id as team_id,
t.name as team_name

from contacts c
join contacts_cstm cc on c.id=cc.id_c
join teams t on c.team_id = t.id);
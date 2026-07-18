-- Filtro de caracteres — rode no Supabase (SQL Editor), na ordem abaixo.
-- Permitidos: letras do português (com acentos), números, espaço e
-- pontuação básica ( . , - : ; ' ? ! / º ª ). Todo o resto é proibido.

-- 0. Conserto pontual do seed: '²' (g/m²) não está no conjunto permitido.
update assinaturas set mensagem = replace(mensagem, '²', '2') where mensagem like '%²%';

-- 1. Apaga as assinaturas existentes que violam o critério.
delete from assinaturas
where nome !~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$'
   or mensagem !~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$'
   or (titulo is not null
       and titulo !~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$');

-- 2. Trava no banco: rejeita inserções com caracteres proibidos,
--    mesmo de quem chamar a API diretamente, sem passar pelo site.
alter table assinaturas
  add constraint chk_nome_caracteres
  check (nome ~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$');

alter table assinaturas
  add constraint chk_titulo_caracteres
  check (titulo is null or titulo ~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$');

alter table assinaturas
  add constraint chk_mensagem_caracteres
  check (mensagem ~ '^[a-zA-Z0-9áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ .,:;''?!/ºª-]+$');

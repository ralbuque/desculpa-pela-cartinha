-- Anti-duplicatas — rode no Supabase (SQL Editor), na ordem abaixo.

-- 1. Limpa repetidos existentes: para cada mensagem (ignorando
--    maiúsculas/minúsculas), mantém só a mais antiga.
delete from assinaturas
where id not in (
  select distinct on (lower(mensagem)) id
  from assinaturas
  order by lower(mensagem), created_at asc, id asc
);

-- 2. Trava: proíbe nova assinatura com mensagem idêntica a uma já
--    existente (ignorando maiúsculas/minúsculas), inclusive via API.
create unique index uniq_mensagem on assinaturas (lower(mensagem));

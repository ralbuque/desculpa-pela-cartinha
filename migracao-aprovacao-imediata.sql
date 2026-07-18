-- Migração: aprovação imediata — rode no Supabase (SQL Editor).
-- Assinaturas novas entram aprovadas e aparecem direto no mural.
-- Para retirar uma depois: Table Editor → assinaturas → aprovado = false.

alter table assinaturas alter column aprovado set default true;

drop policy "envio publico" on assinaturas;
create policy "envio publico" on assinaturas
  for insert to anon
  with check (true);

-- A política de leitura continua igual: só aprovado = true aparece no site.

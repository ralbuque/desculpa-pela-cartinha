# Setup — desculpapelacartinha.com

O site é um único arquivo (`index.html`). Sem o banco configurado ele já funciona com assinaturas de exemplo. Três passos para colocar no ar de verdade:

## 1. Banco de dados (Supabase, grátis)

1. Crie uma conta em [supabase.com](https://supabase.com) e um projeto novo (região `sa-east-1`, São Paulo).
2. Em **SQL Editor**, rode:

```sql
create table assinaturas (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  nome text not null check (char_length(nome) between 1 and 80),
  titulo text check (char_length(titulo) <= 100),
  mensagem text not null check (char_length(mensagem) between 1 and 500),
  aprovado boolean not null default false
);

alter table assinaturas enable row level security;

-- qualquer visitante pode enviar, mas nunca já-aprovado
create policy "envio publico" on assinaturas
  for insert to anon
  with check (aprovado = false);

-- visitantes só leem o que foi aprovado
create policy "leitura de aprovados" on assinaturas
  for select to anon
  using (aprovado = true);
```

3. Em **Settings → API**, copie a **Project URL** e a **anon public key**.
4. No `index.html`, preencha as duas constantes no topo do `<script>`:

```js
const SUPABASE_URL = "https://SEU-PROJETO.supabase.co";
const SUPABASE_ANON_KEY = "sua-anon-key";
```

A anon key é pública por design — a segurança vem das políticas acima (ninguém consegue aprovar, editar ou apagar nada pelo navegador).

## 2. Moderação

Modo atual: **publicação imediata** (após rodar `migracao-aprovacao-imediata.sql` no SQL Editor). Assinaturas novas entram com `aprovado = true` e aparecem direto no mural.

Para retirar uma assinatura do ar: **Table Editor → assinaturas**, mude `aprovado` para `false` (ou delete a linha). Só linhas com `aprovado = true` aparecem no site.

Para voltar ao modo de aprovação prévia, rode no SQL Editor:

```sql
alter table assinaturas alter column aprovado set default false;
drop policy "envio publico" on assinaturas;
create policy "envio publico" on assinaturas
  for insert to anon
  with check (aprovado = false);
```

## 3. Hospedagem + domínio

Qualquer host estático grátis serve. Com Netlify (mais simples):

1. Em [netlify.com](https://app.netlify.com), arraste a pasta com o `index.html` para "Deploy manually" (Sites → Add new site → Deploy manually).
2. Em **Domain settings → Add custom domain**, adicione `desculpapelacartinha.com`.
3. No painel da GoDaddy (Portfolio → desculpapelacartinha.com → DNS), crie:
   - Registro **A**: host `@` → `75.2.60.5` (IP do Netlify; confirme o valor que o Netlify mostrar)
   - Registro **CNAME**: host `www` → `SEU-SITE.netlify.app`
4. Aguarde a propagação (minutos a algumas horas). O Netlify emite HTTPS sozinho.

Alternativas equivalentes: Vercel ou Cloudflare Pages — mesmo fluxo (deploy do arquivo, apontar DNS na GoDaddy).

## Atualizações futuras

Como é um arquivo só, atualizar o site = editar `index.html` e arrastar de novo no Netlify.

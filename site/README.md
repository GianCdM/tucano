# Site do Tucano

Página única e estática: `index.html` (CSS e JS embutidos) e `assets/`. Não precisa de build.

- **Ver:** abra `index.html` no navegador. `index.html?shot` mostra tudo de uma vez (pra capturas).
- **Idiomas:** português e inglês, com o seletor PT | EN no topo. Todo texto está escrito nos dois, lado a lado (`<span lang="pt-BR">` e `<span lang="en">`), e o CSS mostra o do `<html lang>`; o que os scripts desenham passa por `T(pt, en)`. Sem escolha salva, abre em português se o navegador estiver em português, senão em inglês.
- **Identidade:** as formas do ícone do app (o corpo redondo, o olho, o bico em dois laranjas) em creme, preto e laranja. O tucano da abertura, o do rodapé e os agentes seguem o cursor com os olhos.
- **Telas do app:** desenhadas em HTML, não são prints. O canal #checkout da seção "Ao vivo" toca sozinho e espera o visitante aprovar.
- **Fontes:** Bricolage Grotesque (títulos) e Inter (texto), do Google Fonts.
- **Logos:** `assets/logos/` vêm do [Simple Icons](https://simpleicons.org) (CC0).
- **Publicar:** qualquer host estático serve a pasta como está (GitHub Pages, Netlify, Cloudflare Pages).

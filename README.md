Oficina Mecânica — Modelagem de Banco de Dados SQL

📌 Sobre o projeto

Este projeto foi desenvolvido como parte de um desafio de modelagem de banco de dados, com o objetivo de construir um modelo lógico relacional para gerir as operações de uma oficina mecânica.

A solução contempla o cadastro de clientes, veículos, mecânicos, equipas de mecânicos, serviços, peças, ordens de serviço, mão de obra aplicada, peças utilizadas e pagamentos.

O banco de dados foi implementado em MySQL, utilizando o MySQL Workbench para a criação do esquema, execução dos scripts SQL, persistência de dados de teste e elaboração do diagrama EER.

🎯 Objetivos

Criar o esquema lógico de uma oficina mecânica.

Definir tabelas, chaves primárias e chaves estrangeiras.

Estabelecer relacionamentos entre as entidades.

Inserir dados de teste para validar o modelo.

Desenvolver consultas SQL para responder a questões de negócio.

Utilizar filtros, agregações, atributos derivados, ordenações, HAVING e junções.

Documentar o projeto para disponibilização no GitHub.

🗂️ Modelo lógico

O banco de dados utiliza o esquema oficina_mecanica e contém as seguintes tabelas:

Tabela

Finalidade

cliente

Armazena os dados dos clientes.

veiculo

Regista os veículos associados aos clientes.

mecanico

Armazena os dados dos mecânicos.

equipe_mecanicos

Representa as equipas de mecânicos.

equipe_mecanico

Relaciona os mecânicos às equipas.

servico

Regista os serviços disponibilizados pela oficina.

peca

Armazena as peças, os preços e os dados de stock.

ordem_servico

Regista as ordens de serviço, os veículos e os responsáveis.

mao_obra_os

Regista os serviços e respetivos valores de mão de obra por ordem.

peca_os

Regista as peças utilizadas em cada ordem de serviço.

pagamento

Armazena os pagamentos associados às ordens de serviço.

🔗 Principais relacionamentos

Cliente — Veículo: um cliente pode possuir vários veículos.

Veículo — Ordem de serviço: um veículo pode estar associado a várias ordens de serviço.

Equipa — Mecânicos: uma equipa pode ter vários mecânicos.

Mecânico — Ordem de serviço: um mecânico pode ser responsável por várias ordens.

Ordem de serviço — Mão de obra: uma ordem pode conter vários serviços.

Serviço — Mão de obra: um serviço pode ser aplicado em várias ordens.

Ordem de serviço — Peças: uma ordem pode utilizar várias peças.

Peça — Ordem de serviço: uma peça pode ser utilizada em diferentes ordens.

Ordem de serviço — Pagamento: uma ordem pode ter registos de pagamento associados.

As tabelas associativas permitem representar relacionamentos de muitos para muitos, mantendo os dados organizados e reduzindo a duplicação de informação.

⚙️ Regras de negócio

O modelo contempla as seguintes regras:

Cada cliente possui um identificador próprio.

Cada veículo está associado a um cliente.

Cada ordem de serviço possui um identificador e pode estar associada a um veículo.

Os serviços e as peças aplicados numa ordem são registados nas respetivas tabelas associativas.

Os valores de mão de obra e das peças permitem calcular os custos de cada ordem.

Os pagamentos são associados às ordens de serviço.

O estado da ordem permite distinguir ordens em diferentes fases do processo.

📊 Consultas SQL e questões de negócio

O script oficina_mecanica.sql reúne as instruções de criação do banco de dados, a estrutura das tabelas, os dados de teste e as consultas desenvolvidas para o projeto.

As consultas permitem responder, entre outras, às seguintes questões:

Quantos clientes, veículos, mecânicos, serviços e peças existem registados?

Quais são os veículos de cada cliente e a respetiva quilometragem?

Quais são as ordens de serviço e os seus estados?

Quais são os serviços associados a cada ordem?

Qual é o custo da mão de obra por ordem de serviço?

Qual é o custo das peças utilizadas em cada ordem?

Qual é o custo total estimado de uma ordem, considerando mão de obra e peças?

Quais são os serviços mais utilizados e quanto representam em mão de obra?

Como se distribuem os pagamentos por forma de pagamento?

Existem ordens de serviço sem serviços ou peças associados?

Existem pagamentos sem uma ordem de serviço correspondente?

Quais são os veículos com maior quilometragem?

As consultas incluem SELECT, WHERE, expressões calculadas, ORDER BY, GROUP BY, HAVING e junções entre tabelas.

🛠️ Tecnologias utilizadas

MySQL

MySQL Workbench

SQL

Git

GitHub

📁 Estrutura do repositório

oficina-mecanica/
├── README.md
├── oficina_mecanica.sql
└── modelo_eer_oficina.png

Os nomes dos ficheiros acima representam a estrutura pretendida. Devem corresponder aos ficheiros efetivamente guardados no repositório.

▶️ Como executar o projeto

Instalar o MySQL Server e o MySQL Workbench.

Clonar ou descarregar este repositório.

Abrir o ficheiro SQL no MySQL Workbench.

Rever o script antes de o executar, especialmente as instruções de remoção ou recriação do banco de dados.

Executar o script para criar o esquema, as tabelas e os dados de teste.

Executar individualmente as consultas para analisar os resultados.

Atenção: o script pode conter uma instrução DROP DATABASE IF EXISTS. A sua execução elimina o banco de dados existente com esse nome. Se já existirem dados que pretendes preservar, faz uma cópia de segurança antes de executar o script.

🧠 Aprendizagens

Este projeto permitiu praticar a modelagem relacional, a definição de chaves primárias e estrangeiras, a criação de tabelas associativas, a persistência de dados e a elaboração de consultas SQL orientadas para questões de negócio.

Também permitiu compreender como relacionar dados operacionais para obter indicadores úteis à gestão de uma oficina mecânica.

👨‍💻 Autor

Projeto desenvolvido para fins de aprendizagem e portefólio na área de análise de dados e bases de dados relacionais.
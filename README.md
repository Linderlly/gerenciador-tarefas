#  Gerenciador de Tarefas para Pais e Filhos

Aplicativo mobile desenvolvido em **Flutter** com **Firebase**, que permite pais gerenciarem tarefas e recompensas dos filhos de forma simples e motivadora.

---

## Funcionalidades

 **Sistema de usuários**
- Cadastro e login com Firebase Authentication
- Diferenciação entre **Pais** e **Filhos**

 **Tarefas**
- Pais criam tarefas para os filhos
- Filhos visualizam e concluem tarefas
- Sistema de pontuação automática

 **Sistema de pontos**
- Acúmulo de pontos ao concluir tarefas
- Atualização em tempo real

 **Recompensas**
- Pais criam recompensas
- Filhos podem resgatar com pontos

 **Experiência personalizada**
- Mensagem de boas-vindas com nome do usuário

---

## Tecnologias utilizadas

- Flutter
- Firebase Authentication
- Cloud Firestore
- Dart

---

## Estrutura do projeto

```

lib/
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── parent_screen.dart
│   ├── child_screen.dart
│   └── reward_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── task_service.dart
│   └── reward_service.dart
│
└── main.dart

````

---

## Como rodar o projeto

1. Clone o repositório:

```bash
git clone https://github.com/SEU-USUARIO/gerenciador-tarefas.git
````

2. Acesse a pasta:

```bash
cd gerenciador-tarefas
```

3. Instale as dependências:

```bash
flutter pub get
```

4. Configure o Firebase:

* Adicione o arquivo `google-services.json` (Android)
* Configure o `firebase_options.dart`

5. Execute o app:

```bash
flutter run
```

---

## Funcionalidades futuras

*  Notificações
*  Conexão automática entre pais e filhos
*  Ranking de pontos
*  Interface aprimorada
*  Histórico de tarefas

---

## Screenshots (adicione aqui depois)

> Em breve...

---

## Autor

Desenvolvido por **Linderlly Santana**

---

## Licença

Este projeto está sob a licença MIT.

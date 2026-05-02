# 📱 App de Tarefas em Família

Aplicativo desenvolvido em Flutter para gerenciamento de tarefas entre responsáveis e filhos, com sistema de pontos, recompensas, calendário e controle de hábitos.

---

## 🚀 Funcionalidades

### 👨‍👩‍👧‍👦 Sistema de usuários
- Login com Firebase Authentication
- Separação entre responsável (parent) e filho (child)
- Uso de código de família para conexão entre contas

---

### ✅ Tarefas
- Responsável pode criar tarefas
- Definição de pontuação para cada tarefa
- Associação de tarefas por data
- Filho pode concluir tarefas e ganhar pontos

---

### 📅 Calendário
- Visualização de tarefas por dia
- Indicação visual de dias com tarefas
- Integração com tarefas criadas pelo responsável
- Disponível na navegação (Drawer) e no Child

---

### 🎁 Recompensas
- Responsável pode criar recompensas
- Definição de custo em pontos
- Sistema de troca de pontos pelo filho

---

### 💧 Controle de hidratação
- Responsável define meta diária de água (ml)
- Filho registra consumo com botão rápido (+200ml)
- Barra circular de progresso (0% a 100%)
- Exibição da porcentagem para responsáveis e filhos

---

### 🌙 Modo escuro
- Alternância entre modo claro e escuro
- Correção de contraste para melhor leitura
- Aplicado nas principais telas do app

---

## 🧱 Tecnologias utilizadas

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Table Calendar (pacote)

---

## 📂 Estrutura principal
lib/
├── screens/
│ ├── parent_screen.dart
│ ├── child_screen.dart
│ ├── calendar_screen.dart
│
├── services/
│ ├── task_service.dart
│ ├── reward_service.dart
│
├── widgets/
│ ├── app_drawer.dart
│ ├── custom_button.dart


---

## 🔥 Funcionalidades recentes

- Adição do modo escuro
- Integração do calendário com tarefas
- Remoção do calendário da tela principal do responsável
- Melhor organização da navegação
- Sistema de hidratação com progresso visual
- Limitação visual do progresso até 100%

---

## 📌 Melhorias futuras

- Reset automático diário da água
- Notificações de tarefas
- Histórico de tarefas concluídas
- Ranking entre filhos
- Animações e melhorias visuais

---

## ⚙️ Como rodar o projeto

```bash
flutter pub get
flutter run

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

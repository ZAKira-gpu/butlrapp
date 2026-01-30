# Butlr AI Task Manager 🤖📝

Butlr is a modern, AI-powered task management application designed to simplify your life through natural language understanding. Whether you're typing or speaking, Butlr understands your intent, extracts task details, and organizes your schedule with elegance.

## ✨ Visual Overview

<img width="375" height="812" alt="splash screen" src="https://github.com/user-attachments/assets/17fa4c32-52ed-47ba-a64f-b0121f85e506" />                  <img width="375" height="812" alt="ai screen" src="https://github.com/user-attachments/assets/2548c7a2-bbe4-408e-9dd3-be034fc30900" />                    <img width="375" height="812" alt="ai 1" src="https://github.com/user-attachments/assets/faec17dc-f27c-43d6-b654-06473d4b13a3" />                                    

<img width="375" height="812" alt="task" src="https://github.com/user-attachments/assets/87f2501c-2ffa-4929-9246-91c6d3f65e36" />



## 🌟 Key Features in Detail

### 💬 Conversational AI Engine
Butlr isn't just a list; it's an assistant. Powered by **Novita AI (Llama 3.1)**, it processes your natural language to:
- **Extract Intent**: Understands if you want to create, delete, or just check your schedule.
- **Identify Entities**: Pulls out dates ("next Friday"), times ("at noon"), and priorities ("urgent medical appointment").
- **Contextual Memory**: Remembers previous messages so you can say "change *that* to 4pm" and it knows what you mean.

### 📅 Dynamic Scheduling & Calendar
- **Horizontal Date Strip**: Quickly jump between days with a sleek scrolling date picker.
- **Smart Grouping**: Automatically organizes your main list into *Overdue*, *Today*, *Tomorrow*, and *Upcoming* buckets.
- **Recurring Intelligence**: Just say "every Monday" and Butlr handles the rest, projecting your tasks into the future.

### ⏱️ Live Time Tracking
- **Current Time Indicator**: Never lose track of your day. A bright red line moves dynamically through your schedule and calendar views, showing you exactly where you are relative to your tasks.

### 🎨 Premium Design System
- **Glassmorphism**: Elegant, semi-transparent UI elements for a high-end feel.
- **Dark Mode Optimization**: Designed for readability and aesthetic appeal in low-light environments.
- **Micro-animations**: Smooth transitions and gestures (like swipe-to-snooze) for a fluid user experience.

## 🚀 Technology Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev) (Web, Android, iOS)
- **State Management**: Reactive Listenable pattern.
- **Icons**: Lucide Icons & Custom SVG assets.

### Backend
- **Framework**: [Serverpod](https://serverpod.dev) (The real-time server for Flutter).
- **Database**: PostgreSQL (managed via Docker locally).
- **Security**: Environment-based secret management for API keys.

### AI Intelligence
- **Primary LLM**: Llama 3.1 via [Novita AI](https://novita.ai/).
- **Protocol**: OpenAI-compatible REST API integration.

## 🛠️ Getting Started

### 1. Backend Setup
```powershell
cd butlrapp_server
docker-compose up -d
dart bin/main.dart --apply-migrations
```

### 2. Frontend Setup
```powershell
cd butlrapp_flutter
flutter pub get
flutter run
```

## 🌍 Live Deployment

Butlr is hosted on **Serverpod Cloud**.

- **Web App**: [https://butlr1.serverpod.space/app/](https://butlr1.serverpod.space/app/)
- **API Endpoint**: [https://butlr1.api.serverpod.space/](https://butlr1.api.serverpod.space/)
- **Admin Dashboard**: [https://butlr1.insights.serverpod.space/](https://butlr1.insights.serverpod.space/)

---
Created for Hackathon 2026. 🚀

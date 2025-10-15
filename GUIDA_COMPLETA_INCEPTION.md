# GUIDA COMPLETA PROGETTO INCEPTION
## Docker Infrastructure con WordPress, Nginx, MariaDB e Servizi Bonus

**Autore**: Stefano Di Puma  
**Progetto**: 42 School - Inception  
**Data**: Agosto 2025

---

## INDICE

1. [Introduzione](#introduzione)
2. [Concetti Teorici Fondamentali](#concetti-teorici-fondamentali)
3. [Struttura del Progetto](#struttura-del-progetto)
4. [File di Configurazione Principali](#file-di-configurazione-principali)
5. [Servizi Obbligatori](#servizi-obbligatori)
6. [Servizi Bonus](#servizi-bonus)
7. [Sicurezza e Best Practices](#sicurezza-e-best-practices)
8. [Comandi di Gestione](#comandi-di-gestione)
9. [Troubleshooting](#troubleshooting)

---

## INTRODUZIONE

Il progetto Inception consiste nella creazione di una piccola infrastruttura composta da diversi servizi utilizzando Docker e Docker Compose. L'obiettivo è implementare un sistema LEMP (Linux, Engine-X/Nginx, MySQL/MariaDB, PHP) completamente containerizzato con funzionalità aggiuntive.

### Tecnologie Utilizzate
- **Docker**: Containerizzazione dei servizi
- **Docker Compose**: Orchestrazione dei container
- **Nginx**: Web server con supporto TLS
- **WordPress**: CMS con PHP-FPM
- **MariaDB**: Database relazionale
- **Debian Bullseye**: Sistema operativo base per tutti i container

---

## CONCETTI TEORICI FONDAMENTALI

### 1. CONTAINERIZZAZIONE E DOCKER

#### 1.1 Cos'è la Containerizzazione?

La **containerizzazione** è una tecnologia di virtualizzazione a livello di sistema operativo che permette di eseguire applicazioni in ambienti isolati chiamati container. A differenza delle macchine virtuali tradizionali, i container condividono il kernel del sistema operativo host, risultando più leggeri e efficienti.

**Caratteristiche principali:**
- **Isolamento**: Ogni container ha il proprio filesystem, spazio di rete e spazio dei processi
- **Portabilità**: I container funzionano identicamente su qualsiasi sistema che supporti Docker
- **Efficienza**: Minimo overhead rispetto alle VM tradizionali
- **Scalabilità**: Avvio rapido e facile replicazione
- **Immutabilità**: Le immagini sono read-only, garantendo consistenza

#### 1.2 Docker: Architettura e Componenti

**Docker** è una piattaforma open-source per lo sviluppo, il deployment e l'esecuzione di applicazioni usando container.

**Componenti principali:**

1. **Docker Engine**: Runtime che gestisce container, immagini, volumi e reti
2. **Docker Images**: Template read-only per creare container
3. **Docker Containers**: Istanze eseguibili delle immagini
4. **Dockerfile**: File di testo con istruzioni per costruire immagini
5. **Docker Registry**: Repository per condividere immagini (es. Docker Hub)

**Architettura Docker:**
```
┌─────────────────────────────────────────────────────────┐
│                  Docker Client                         │
│                 (docker commands)                      │
└─────────────────────┬───────────────────────────────────┘
                      │ REST API
┌─────────────────────┴───────────────────────────────────┐
│                 Docker Daemon                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐│
│  │  Container  │ │  Container  │ │     Images          ││
│  │  Management │ │  Runtime    │ │     Management      ││
│  └─────────────┘ └─────────────┘ └─────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

#### 1.3 Lifecycle dei Container

1. **BUILD**: Creazione immagine da Dockerfile
2. **SHIP**: Distribuzione immagine via registry
3. **RUN**: Esecuzione container da immagine

### 2. ORCHESTRAZIONE E DOCKER COMPOSE

#### 2.1 Cos'è l'Orchestrazione?

L'**orchestrazione** è il processo automatizzato di coordinamento e gestione di multiple applicazioni containerizzate. Include:

- **Deployment**: Distribuzione automatica dei container
- **Scaling**: Aumento/diminuzione automatica delle istanze
- **Load Balancing**: Distribuzione del carico tra container
- **Service Discovery**: Rilevamento automatico dei servizi
- **Health Monitoring**: Monitoraggio dello stato dei container
- **Rolling Updates**: Aggiornamenti senza downtime

#### 2.2 Docker Compose: Orchestrazione Locale

**Docker Compose** è uno strumento per definire ed eseguire applicazioni Docker multi-container usando file YAML.

**Vantaggi:**
- **Declarative Configuration**: Definizione dell'infrastruttura come codice
- **Service Dependencies**: Gestione delle dipendenze tra servizi
- **Network Management**: Creazione automatica di reti isolate
- **Volume Management**: Gestione centralizzata dei volumi
- **Environment Management**: Configurazione per ambienti diversi

**Flusso di lavoro Docker Compose:**
```
docker-compose.yml → Docker Compose → Container Network
                ↓
        ┌───────────────┐
        │   Service 1   │──┐
        └───────────────┘  │
        ┌───────────────┐  │  Shared Network
        │   Service 2   │──┤  & Volumes
        └───────────────┘  │
        ┌───────────────┐  │
        │   Service 3   │──┘
        └───────────────┘
```

#### 2.3 YAML: Sintassi e Best Practices

**YAML** (YAML Ain't Markup Language) è un formato di serializzazione dati human-readable.

**Sintassi fondamentale:**
```yaml
# Commento
chiave: valore                    # String
numero: 42                       # Number
booleano: true                   # Boolean
lista:                          # Array
  - elemento1
  - elemento2
oggetto:                        # Object
  proprieta1: valore1
  proprieta2: valore2
multilinea: |                   # Multiline string
  Testo che mantiene
  le interruzioni di linea
```

**Best Practices YAML:**
- Usare 2 spazi per indentazione (mai tab)
- Quotes opzionali per stringhe semplici
- Usare `|` per testo multilinea che mantiene newline
- Usare `>` per testo multilinea che rimuove newline

### 3. ARCHITETTURA WEB E STACK LEMP

#### 3.1 Cos'è uno Stack Web?

Uno **stack web** è un insieme di tecnologie software utilizzate per sviluppare applicazioni web. Include:

1. **Sistema Operativo**: Piattaforma base (Linux)
2. **Web Server**: Server HTTP (Nginx)
3. **Database**: Sistema di gestione dati (MariaDB)
4. **Linguaggio di Programmazione**: Runtime applicazione (PHP)

#### 3.2 Stack LEMP

**LEMP** sta per:
- **L**inux: Sistema operativo
- **E**ngine-X (Nginx): Web server
- **M**ySQL/MariaDB: Database
- **P**HP: Linguaggio di programmazione

**Architettura LEMP:**
```
Internet → Nginx → PHP-FPM → MariaDB
    ↓         ↓        ↓         ↓
  Port 80   Reverse  FastCGI   Port 3306
  Port 443   Proxy   Process   Database
```

#### 3.3 Nginx: Web Server e Reverse Proxy

**Nginx** è un web server HTTP e reverse proxy ad alte prestazioni.

**Caratteristiche:**
- **Event-driven**: Architettura asincrona non-blocking
- **High Performance**: Gestione efficiente di molte connessioni simultanee
- **Low Resource Usage**: Consumo di memoria ridotto
- **Reverse Proxy**: Può fungere da proxy per altri server
- **Load Balancer**: Distribuzione del carico tra backend
- **SSL Termination**: Gestione crittografia SSL/TLS

**Architettura Nginx:**
```
                    Master Process
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   Worker Process   Worker Process   Worker Process
        │                │                │
   Event Loop       Event Loop       Event Loop
   (connections)    (connections)    (connections)
```

**Configurazione Nginx - Struttura:**
```nginx
# Contesto principale
user nginx;
worker_processes auto;

# Contesto eventi
events {
    worker_connections 1024;
}

# Contesto HTTP
http {
    # Configurazioni globali HTTP
    
    # Contesto server
    server {
        listen 80;
        server_name example.com;
        
        # Contesto location
        location / {
            # Configurazioni per path specifici
        }
    }
}
```

#### 3.4 FastCGI e PHP-FPM

**FastCGI** è un protocollo per interfacciare programmi esterni con web server.

**PHP-FPM** (FastCGI Process Manager) è un'implementazione FastCGI per PHP con funzionalità avanzate:

- **Process Management**: Gestione automatica dei processi PHP
- **Performance**: Pool di processi pre-forked per prestazioni ottimali
- **Monitoring**: Monitoraggio stato e performance
- **Graceful Restart**: Riavvio senza interruzione servizio
- **Resource Limits**: Controllo utilizzo risorse per processo

**Flusso richiesta Nginx → PHP-FPM:**
```
1. Client → Nginx (HTTP Request)
2. Nginx → PHP-FPM (FastCGI Request)
3. PHP-FPM → PHP Script (Process Request)
4. PHP Script → Database (Query if needed)
5. Database → PHP Script (Result)
6. PHP Script → PHP-FPM (Response)
7. PHP-FPM → Nginx (FastCGI Response)
8. Nginx → Client (HTTP Response)
```

### 4. DATABASE E PERSISTENZA

#### 4.1 Sistemi di Gestione Database (DBMS)

Un **DBMS** è un software per creare, gestire e interrogare database.

**Tipi di database:**
1. **Relazionali (RDBMS)**: Dati organizzati in tabelle con relazioni (MySQL, MariaDB, PostgreSQL)
2. **NoSQL**: Dati non-relazionali (MongoDB, Redis, Cassandra)
3. **In-Memory**: Dati in RAM per prestazioni estreme (Redis, Memcached)

#### 4.2 MariaDB: Fork MySQL

**MariaDB** è un fork open-source di MySQL, creato dal fondatore originale di MySQL.

**Vantaggi MariaDB:**
- **Open Source**: Completamente libero
- **Performance**: Ottimizzazioni per velocità
- **Storage Engines**: Supporto motori di storage multipli
- **Compatibility**: Compatibile con MySQL
- **Security**: Funzionalità di sicurezza avanzate

**Architettura MariaDB:**
```
┌─────────────────────────────────────────────────────────┐
│                Connection Pool                          │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                  SQL Layer                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐│
│  │   Parser    │ │  Optimizer  │ │      Cache          ││
│  └─────────────┘ └─────────────┘ └─────────────────────┘│
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│               Storage Engine Layer                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐│
│  │   InnoDB    │ │    MyISAM   │ │       Other         ││
│  └─────────────┘ └─────────────┘ └─────────────────────┘│
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                File System                              │
└─────────────────────────────────────────────────────────┘
```

#### 4.3 Persistenza Dati in Docker

**Problemi persistenza container:**
- Container sono **efimeri**: dati persi quando container viene rimosso
- **Layer filesystem**: Modifiche sui layer container sono temporanee

**Soluzioni persistenza:**

1. **Docker Volumes**: Gestiti da Docker Engine
   ```bash
   docker volume create myvolume
   docker run -v myvolume:/data myimage
   ```

2. **Bind Mounts**: Mount directory host nel container
   ```bash
   docker run -v /host/path:/container/path myimage
   ```

3. **tmpfs Mounts**: Mount in memoria RAM
   ```bash
   docker run --tmpfs /tmp myimage
   ```

**Confronto metodi persistenza:**
```
┌─────────────────┬──────────────┬──────────────┬──────────────┐
│     Feature     │   Volumes    │ Bind Mounts  │    tmpfs     │
├─────────────────┼──────────────┼──────────────┼──────────────┤
│ Performance     │     High     │    Medium    │   Highest    │
│ Portability     │     High     │     Low      │    Medium    │
│ Docker Management│     Yes      │      No      │      No      │
│ Host Access     │     No       │     Yes      │      No      │
│ Persistence     │     Yes      │     Yes      │      No      │
└─────────────────┴──────────────┴──────────────┴──────────────┘
```

### 5. NETWORKING E SICUREZZA

#### 5.1 Docker Networking

**Docker** crea network virtuali per permettere comunicazione tra container.

**Tipi di driver network:**

1. **bridge**: Network isolato su singolo host (default)
2. **host**: Container usa network stack dell'host
3. **overlay**: Network multi-host per swarm
4. **macvlan**: Assegna MAC address ai container
5. **none**: Disabilita networking

**Bridge Network (default):**
```
Host Network (eth0: 192.168.1.100)
    │
    └── Docker Bridge (docker0: 172.17.0.1)
            │
            ├── Container 1 (172.17.0.2)
            ├── Container 2 (172.17.0.3)
            └── Container 3 (172.17.0.4)
```

**Custom Bridge Network:**
```yaml
networks:
  custom_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

#### 5.2 TLS/SSL: Crittografia Trasporto

**TLS** (Transport Layer Security) è un protocollo crittografico per comunicazioni sicure.

**Versioni TLS:**
- **TLS 1.0**: Obsoleto (vulnerabile)
- **TLS 1.1**: Obsoleto (vulnerabile)
- **TLS 1.2**: Sicuro, ampiamente supportato
- **TLS 1.3**: Più recente, performance migliori

**Handshake TLS:**
```
Client                          Server
  │                               │
  │ ────── ClientHello ─────────→ │
  │                               │
  │ ←───── ServerHello ─────────── │
  │ ←──── Certificate ──────────── │
  │ ←── ServerKeyExchange ──────── │
  │ ←─── ServerHelloDone ────────── │
  │                               │
  │ ─── ClientKeyExchange ──────→ │
  │ ──── ChangeCipherSpec ──────→ │
  │ ────── Finished ───────────→ │
  │                               │
  │ ←─── ChangeCipherSpec ──────── │
  │ ←────── Finished ───────────── │
  │                               │
  │ ←──── Encrypted Data ────────→ │
```

**Certificati SSL:**
- **Self-signed**: Creati localmente (sviluppo)
- **CA-signed**: Firmati da Certificate Authority (produzione)
- **Let's Encrypt**: CA gratuita per certificati automatici

#### 5.3 Docker Secrets

**Docker Secrets** è un sistema per gestire dati sensibili in modo sicuro.

**Caratteristiche:**
- **Encryption**: Dati crittografati at-rest e in-transit
- **Access Control**: Solo container autorizzati possono accedere
- **Rotation**: Possibilità di rotazione secrets
- **Audit**: Log degli accessi ai secrets

**Flusso Docker Secrets:**
```
1. Secret creato → Encrypted storage
2. Service deployed → Secret montato in /run/secrets/
3. Application → Legge secret da file
4. Secret updated → Rolling update container
```

### 6. CONTENT MANAGEMENT SYSTEMS (CMS)

#### 6.1 Cos'è WordPress?

**WordPress** è il CMS (Content Management System) più popolare al mondo, utilizzato per creare siti web e blog.

**Architettura WordPress:**
- **Core**: Funzionalità base WordPress
- **Themes**: Template grafici
- **Plugins**: Estensioni funzionalità
- **Database**: Storage contenuti e configurazioni

**Struttura directory WordPress:**
```
wordpress/
├── wp-admin/           # Admin interface
├── wp-content/         # Themes, plugins, uploads
│   ├── themes/
│   ├── plugins/
│   └── uploads/
├── wp-includes/        # Core functions
├── wp-config.php      # Configuration file
└── index.php          # Entry point
```

#### 6.2 WordPress Database Schema

**Tabelle principali:**
- **wp_posts**: Contenuti (post, pagine, media)
- **wp_users**: Utenti registrati
- **wp_comments**: Commenti ai post
- **wp_options**: Configurazioni sito
- **wp_postmeta**: Metadati post
- **wp_usermeta**: Metadati utenti

### 7. CACHING E PERFORMANCE

#### 7.1 Strategie di Caching

**Cache** è una memoria temporanea per dati frequentemente richiesti.

**Livelli di cache:**
1. **Browser Cache**: File statici nel browser client
2. **CDN Cache**: Content Delivery Network geograficamente distribuita
3. **Reverse Proxy Cache**: Cache a livello web server (Nginx)
4. **Application Cache**: Cache a livello applicazione (Redis)
5. **Database Cache**: Query cache nel database

#### 7.2 Redis: In-Memory Database

**Redis** (Remote Dictionary Server) è un database in-memory key-value.

**Caratteristiche:**
- **In-Memory**: Dati in RAM per accesso ultra-rapido
- **Persistence**: Opzioni per persistenza su disco
- **Data Structures**: Supporto strutture dati complesse
- **Atomic Operations**: Operazioni atomiche thread-safe
- **Pub/Sub**: Messaging pattern publish/subscribe

**Strutture dati Redis:**
- **Strings**: Valori semplici
- **Lists**: Liste ordinate
- **Sets**: Insiemi non ordinati
- **Sorted Sets**: Insiemi ordinati con score
- **Hashes**: Mappe key-value
- **Streams**: Log append-only

### 8. FILE TRANSFER PROTOCOL (FTP)

#### 8.1 Protocollo FTP

**FTP** è un protocollo per il trasferimento di file tra client e server.

**Modalità FTP:**
1. **Active Mode**: Server inizia connessione dati verso client
2. **Passive Mode**: Client inizia connessione dati verso server

**Canali FTP:**
- **Control Channel**: Porta 21, comandi FTP
- **Data Channel**: Porta 20 (active) o dinamica (passive)

**Problemi FTP tradizionale:**
- **Security**: Password in chiaro
- **Firewall**: Problemi con NAT e firewall
- **Encryption**: Nessuna crittografia

**Soluzioni moderne:**
- **SFTP**: SSH File Transfer Protocol
- **FTPS**: FTP over SSL/TLS
- **SCP**: Secure Copy Protocol

### 9. MONITORING E MANAGEMENT

#### 9.1 Database Administration Tools

**Adminer** è uno strumento web per gestione database.

**Vantaggi Adminer:**
- **Single File**: Un solo file PHP
- **Multi-DB**: Supporto multiple database
- **Themes**: Interfacce personalizzabili
- **Security**: Configurazioni sicurezza
- **Export/Import**: Funzionalità backup/restore

**Confronto tool database:**
```
┌─────────────┬──────────────┬──────────────┬──────────────┐
│    Tool     │   Complexity │    Features  │  Installation│
├─────────────┼──────────────┼──────────────┼──────────────┤
│  Adminer    │     Low      │    Medium    │     Easy     │
│ phpMyAdmin  │    Medium    │     High     │    Medium    │
│   DBeaver   │     High     │   Very High  │     Hard     │
│ MySQL WB    │     High     │   Very High  │     Hard     │
└─────────────┴──────────────┴──────────────┴──────────────┘
```

### 10. AUTOMAZIONE E DEVOPS

#### 10.1 Makefile: Automazione Build

**Make** è uno strumento per automatizzare la compilazione e gestione progetti.

**Sintassi Makefile:**
```makefile
target: dependencies
	command1
	command2

# Variabili
VAR = value
$(VAR)  # Uso variabile

# Phony targets (non creano file)
.PHONY: clean install
```

**Best Practices Makefile:**
- Usare tab per indentazione comandi
- Definire target `.PHONY` per evitare conflitti
- Usare variabili per path e configurazioni
- Documentare target complessi

#### 10.2 Infrastructure as Code (IaC)

**IaC** è la pratica di gestire infrastruttura tramite codice.

**Vantaggi IaC:**
- **Versioning**: Controllo versioni dell'infrastruttura
- **Reproducibility**: Ambiente riproducibile
- **Documentation**: Infrastruttura auto-documentata
- **Testing**: Possibilità di testare configurazioni
- **Collaboration**: Team collaboration su infrastruttura

**Tools IaC:**
- **Docker Compose**: Container orchestration
- **Terraform**: Multi-cloud infrastructure
- **Ansible**: Configuration management
- **Kubernetes**: Container orchestration at scale

### 11. PATTERN ARCHITETTURALI E DESIGN

#### 11.1 Microservices Architecture

Il progetto Inception implementa un'architettura a **microservizi**, dove ogni componente funziona come servizio indipendente.

**Caratteristiche microservizi:**
- **Single Responsibility**: Ogni servizio ha una responsabilità specifica
- **Independence**: Deploy e scaling indipendenti
- **Technology Agnostic**: Ogni servizio può usare tecnologie diverse
- **Fault Isolation**: Failure di un servizio non compromette gli altri
- **Data Isolation**: Ogni servizio gestisce i propri dati

**Microservizi nel progetto:**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │────│  WordPress  │────│   MariaDB   │
│ (Web Server)│    │   (CMS)     │    │ (Database)  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │
       └───────────────────┼───────────────────┐
                           │                   │
                  ┌─────────────┐    ┌─────────────┐
                  │    Redis    │    │     FTP     │
                  │  (Cache)    │    │ (File Mgmt) │
                  └─────────────┘    └─────────────┘
```

#### 11.2 Separation of Concerns

**Separation of Concerns** è un principio di design che separa responsabilità diverse in moduli distinti.

**Implementazione nel progetto:**
- **Presentation Layer**: Nginx (HTTP/HTTPS handling)
- **Application Layer**: WordPress (Business logic)
- **Data Layer**: MariaDB (Data persistence)
- **Cache Layer**: Redis (Performance optimization)
- **Management Layer**: Adminer (Database administration)

#### 11.3 Service-Oriented Architecture (SOA)

**SOA** è un paradigma architetturale che organizza applicazioni come collezione di servizi.

**Principi SOA implementati:**
1. **Service Contract**: Interfacce ben definite (HTTP/FastCGI/MySQL protocol)
2. **Service Loose Coupling**: Servizi debolmente accoppiati
3. **Service Abstraction**: Dettagli implementazione nascosti
4. **Service Reusability**: Servizi riutilizzabili in contesti diversi
5. **Service Composability**: Servizi componibili per funzionalità complesse

#### 11.4 Twelve-Factor App Methodology

Il progetto segue molti principi **Twelve-Factor App** per applicazioni cloud-native:

1. **Codebase**: Un repository per applicazione
2. **Dependencies**: Dipendenze esplicite e isolate
3. **Config**: Configurazione in environment variables
4. **Backing Services**: Servizi di supporto come risorse attached
5. **Build/Release/Run**: Separazione netta delle fasi
6. **Processes**: Applicazioni come processi stateless
7. **Port Binding**: Servizi esposti via port binding
8. **Concurrency**: Scale-out via processo model
9. **Disposability**: Avvio veloce e graceful shutdown
10. **Dev/Prod Parity**: Ambienti simili
11. **Logs**: Log come stream eventi
12. **Admin Processes**: Task admin come one-off processes

### 12. SICUREZZA INFORMATICA

#### 12.1 Defense in Depth

**Defense in Depth** è una strategia di sicurezza che implementa multiple layer di protezione.

**Layer di sicurezza nel progetto:**
```
┌─────────────────────────────────────────────────────────┐
│                 Network Security                        │
│  (Firewall, Network Segmentation, TLS)                │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│               Application Security                      │
│  (Input Validation, Output Encoding, Auth)            │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                 Host Security                           │
│  (Container Isolation, User Permissions)              │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                 Data Security                           │
│  (Encryption, Access Control, Secrets Management)     │
└─────────────────────────────────────────────────────────┘
```

#### 12.2 Principio del Privilegio Minimo

**Least Privilege Principle**: Ogni utente/processo dovrebbe avere solo i permessi minimi necessari.

**Implementazione nel progetto:**
- **Container Users**: Processi eseguiti con utenti non-root
- **File Permissions**: Permessi minimi sui file
- **Network Access**: Solo porte necessarie esposte
- **Database Users**: Privilegi specifici per funzione

#### 12.3 Security Headers HTTP

**Security Headers** sono header HTTP che migliorano la sicurezza delle applicazioni web.

**Headers implementati:**
```nginx
# Previene clickjacking
add_header X-Frame-Options DENY;

# Previene MIME type sniffing
add_header X-Content-Type-Options nosniff;

# Abilita XSS protection nel browser
add_header X-XSS-Protection "1; mode=block";

# Forza HTTPS per domini e subdomain
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

# Content Security Policy (avanzato)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'";
```

### 13. PERFORMANCE E SCALABILITÀ

#### 13.1 Performance Tuning

**Performance tuning** è l'ottimizzazione delle prestazioni del sistema.

**Aree di ottimizzazione:**

1. **Web Server (Nginx)**:
   - Worker processes/connections
   - Keep-alive timeout
   - Gzip compression
   - Static file caching

2. **Application (PHP-FPM)**:
   - Process pool sizing
   - Memory limits
   - OPcache configuration

3. **Database (MariaDB)**:
   - Buffer pool size
   - Query cache
   - Index optimization

4. **Caching (Redis)**:
   - Memory allocation
   - Eviction policies
   - Persistence settings

#### 13.2 Monitoring e Observability

**Observability** è la capacità di comprendere lo stato interno di un sistema dai suoi output esterni.

**Three Pillars of Observability:**
1. **Metrics**: Misurazioni numeriche (CPU, memory, response time)
2. **Logs**: Record eventi discreti
3. **Traces**: Tracking richieste attraverso sistemi distribuiti

**Implementazione monitoring:**
```bash
# Metrics container
docker stats

# Log aggregation
docker-compose logs -f

# Health checks
curl -f http://localhost/health || exit 1
```

### 14. CONTINUOUS INTEGRATION/DEPLOYMENT

#### 14.1 CI/CD Pipeline

**CI/CD** (Continuous Integration/Continuous Deployment) automatizza il processo di integrazione e deployment del codice.

**Fasi CI/CD tipiche:**
```
Code Commit → Build → Test → Security Scan → Deploy → Monitor
     │          │      │         │            │        │
     │          │      │         │            │        └─ Rollback if needed
     │          │      │         │            └─ Blue/Green deployment
     │          │      │         └─ Vulnerability scanning
     │          │      └─ Unit/Integration tests
     │          └─ Docker image build
     └─ Version control trigger
```

#### 14.2 GitOps Workflow

**GitOps** è una metodologia che usa Git come single source of truth per infrastructure e applicazioni.

**Principi GitOps:**
1. **Declarative**: Sistema descritto dichiarativamente
2. **Versioned**: Stato versioned in Git
3. **Pulled**: Software agents pull changes automaticamente
4. **Monitored**: Drift detection e remediation

### 15. SYSTEM ADMINISTRATION AVANZATO

#### 15.1 Process Management

**Process Management** è la gestione dei processi in esecuzione nel sistema.

**Concetti fondamentali:**
- **PID 1**: Processo init, padre di tutti i processi
- **Orphan Processes**: Processi il cui padre è terminato
- **Zombie Processes**: Processi terminati ma non ancora "raccolti"
- **Signal Handling**: Comunicazione tra processi via segnali

**Process States:**
```
┌─────────────┐    fork()     ┌─────────────┐
│   CREATED   │──────────────→│   READY     │
└─────────────┘               └─────────────┘
                                     │ schedule
                                     ▼
┌─────────────┐    I/O wait   ┌─────────────┐
│   BLOCKED   │←──────────────│   RUNNING   │
└─────────────┘               └─────────────┘
       │                             │ exit()
       └──────────────┐              ▼
                      │      ┌─────────────┐
                      └─────→│ TERMINATED  │
                             └─────────────┘
```

**Docker e PID 1:**
In Docker, il comando CMD/ENTRYPOINT diventa PID 1. Questo ha implicazioni:
- **Signal Handling**: PID 1 deve gestire correttamente i segnali
- **Zombie Reaping**: PID 1 deve raccogliere processi zombie
- **Graceful Shutdown**: Importante per clean shutdown

#### 15.2 File System e Permissions

**Linux File System Hierarchy:**
```
/                    # Root directory
├── /bin            # Essential binaries
├── /etc            # Configuration files
├── /home           # User home directories
├── /lib            # Shared libraries
├── /opt            # Optional software
├── /tmp            # Temporary files
├── /usr            # User programs
├── /var            # Variable data (logs, cache)
└── /proc           # Process information
```

**Permissions Linux:**
```
rwxrwxrwx = 777
│││││││││
│││││└└└─ Others: read(4) + write(2) + execute(1)
│││└└└─── Group:  read(4) + write(2) + execute(1)
└└└───── Owner:   read(4) + write(2) + execute(1)
```

**Special Permissions:**
- **Setuid (4000)**: Esegui con privilegi del proprietario
- **Setgid (2000)**: Esegui con privilegi del gruppo
- **Sticky bit (1000)**: Solo proprietario può eliminare file

#### 15.3 Network Troubleshooting

**Tools di diagnostica rete:**

1. **ping**: Test connectivity ICMP
   ```bash
   ping -c 4 google.com
   ```

2. **netstat**: Statistiche connessioni rete
   ```bash
   netstat -tulpn  # TCP/UDP listening ports
   ```

3. **ss**: Sostituto moderno di netstat
   ```bash
   ss -tlnp  # TCP listening ports
   ```

4. **tcpdump**: Packet capture
   ```bash
   tcpdump -i eth0 port 80
   ```

5. **nmap**: Network mapping
   ```bash
   nmap -sT -p 1-1000 localhost
   ```

### 16. STORAGE E BACKUP

#### 16.1 Storage Technologies

**Tipi di storage:**
1. **Block Storage**: Accesso raw blocks (SAN, local disks)
2. **File Storage**: Filesystem tradizionale (NFS, SMB)
3. **Object Storage**: Key-value scalabile (S3, Swift)

**RAID Levels:**
- **RAID 0**: Striping (performance, no redundancy)
- **RAID 1**: Mirroring (redundancy, 50% capacity)
- **RAID 5**: Striping + parity (performance + redundancy)
- **RAID 10**: Stripe of mirrors (best performance + redundancy)

#### 16.2 Docker Storage Drivers

**Storage Drivers** gestiscono layer filesystem dei container.

**Tipi storage drivers:**
1. **overlay2**: Default, performance ottimali
2. **aufs**: Legacy, compatibilità
3. **devicemapper**: Block-level, enterprise
4. **btrfs**: Copy-on-write filesystem
5. **zfs**: Enterprise filesystem con snapshot

**Copy-on-Write (CoW):**
```
Original Image Layer (Read-Only)
         │
         ▼
Container Layer (Read-Write)
         │
         ▼
Modified files copied to container layer
```

### 17. LOGGING E AUDIT

#### 17.1 Centralized Logging

**Centralized Logging** raccoglie log da multiple sorgenti in location centrale.

**ELK Stack (Elasticsearch, Logstash, Kibana):**
```
Applications → Logstash → Elasticsearch → Kibana
     │            │            │           │
  Generate      Parse &      Index &     Visualize
    Logs       Transform    Store        & Query
```

**Docker Logging Drivers:**
- **json-file**: Default, file JSON locale
- **syslog**: Invia a syslog daemon
- **journald**: Systemd journal
- **gelf**: Graylog Extended Log Format
- **fluentd**: Unified logging layer

#### 17.2 Log Levels e Best Practices

**Standard Log Levels:**
1. **FATAL**: Errori che causano terminazione applicazione
2. **ERROR**: Errori che non causano terminazione
3. **WARN**: Situazioni potenzialmente problematiche
4. **INFO**: Informazioni generali operazioni
5. **DEBUG**: Informazioni dettagliate per debugging
6. **TRACE**: Informazioni molto dettagliate

**Structured Logging:**
```json
{
  "timestamp": "2025-08-06T10:30:00Z",
  "level": "INFO",
  "service": "nginx",
  "message": "Request processed",
  "request_id": "abc123",
  "duration_ms": 45,
  "status_code": 200
}
```

### 18. HIGH AVAILABILITY E DISASTER RECOVERY

#### 18.1 High Availability Concepts

**High Availability (HA)** è la capacità di un sistema di rimanere operativo per lunghi periodi.

**HA Metrics:**
- **Uptime**: Percentuale tempo operativo
- **RTO**: Recovery Time Objective (tempo massimo downtime)
- **RPO**: Recovery Point Objective (massima perdita dati accettabile)

**Availability Levels:**
```
99.9%    = 8.77 hours downtime/year    (Three 9s)
99.99%   = 52.6 minutes downtime/year  (Four 9s)
99.999%  = 5.26 minutes downtime/year  (Five 9s)
99.9999% = 31.5 seconds downtime/year  (Six 9s)
```

#### 18.2 Load Balancing

**Load Balancing** distribuisce richieste tra multiple istanze di servizio.

**Algoritmi Load Balancing:**
1. **Round Robin**: Distribuzione ciclica
2. **Least Connections**: Server con meno connessioni attive
3. **Weighted Round Robin**: Round robin con pesi
4. **IP Hash**: Basato su hash IP client
5. **Health Check**: Solo server healthy ricevono traffico

**Nginx Load Balancing:**
```nginx
upstream backend {
    least_conn;  # Load balancing method
    server backend1.example.com weight=3;
    server backend2.example.com weight=1;
    server backend3.example.com backup;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

### 19. SECURITY HARDENING

#### 19.1 Container Security

**Container Security Best Practices:**

1. **Image Security**:
   - Use minimal base images
   - Scan images for vulnerabilities
   - Keep images updated
   - Use distroless images quando possibile

2. **Runtime Security**:
   - Run containers as non-root user
   - Use read-only filesystems
   - Limit container capabilities
   - Use security profiles (AppArmor/SELinux)

3. **Network Security**:
   - Use custom networks
   - Implement network policies
   - Encrypt inter-service communication

**Security Scanning:**
```bash
# Scan image vulnerabilities
docker scan nginx:latest

# Check container security
docker run --security-opt no-new-privileges myimage
```

#### 19.2 Secrets Management

**Secrets Management** è la gestione sicura di informazioni sensibili.

**Rotation Strategy:**
```
Active Secret  →  New Secret  →  Deactivate Old  →  Remove Old
      │              │               │                │
   Current use    Deploy new     Grace period     Clean up
```

**Secrets Best Practices:**
- Never commit secrets to version control
- Use encryption at rest and in transit
- Implement secrets rotation
- Apply principle of least privilege
- Audit secrets access

---

## STRUTTURA DEL PROGETTO

```
INCEPTION/
├── Makefile                          # File per automazione build/deploy
├── secrets/                          # Directory per credenziali sensibili
│   ├── credentials.txt              # Credenziali utente WordPress
│   ├── db_password.txt              # Password database WordPress
│   └── db_root_password.txt         # Password root MariaDB
└── srcs/                            # Directory sorgenti principali
    ├── .env                         # Variabili d'ambiente
    ├── .dockerignore               # File da escludere dal build context
    ├── docker-compose.yml          # Configurazione orchestrazione servizi
    └── requirements/               # Directory servizi
        ├── mariadb/               # Servizio database
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init-db.sh
        ├── nginx/                 # Servizio web server
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        ├── wordpress/             # Servizio CMS
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── tools/
        │       └── wp-config.php
        └── bonus/                 # Servizi bonus
            ├── adminer/           # Gestione database web
            ├── ftp/              # Server FTP
            ├── redis/            # Cache Redis
            └── website/          # Sito statico Python
```

---

## FILE DI CONFIGURAZIONE PRINCIPALI

### 1. Makefile

```makefile
# Definisce variabili per paths e nomi
DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/stefanodipuma/data

# Target principale: avvia tutto l'ambiente
all:
	@echo "[*] Avvio dell'infrastruttura Inception..."
	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	cd srcs && docker-compose up -d --build

# Ferma tutti i servizi
down:
	@echo "[*] Fermare i servizi..."
	cd srcs && docker-compose down

# Riavvio completo: down + all
re: fclean all

# Pulizia completa: container, volumi, immagini
fclean:
	@echo "[*] Rimozione totale: container, volumi, immagini..."
	cd srcs && docker-compose down -v --rmi all --remove-orphans
	docker system prune -af
	sudo rm -rf $(DATA_PATH)

# Target di utilità
logs:
	cd srcs && docker-compose logs -f

status:
	cd srcs && docker-compose ps

.PHONY: all down re fclean logs status
```

**Spiegazione linea per linea:**
- `DOCKER_COMPOSE_FILE`: Path al file docker-compose.yml
- `DATA_PATH`: Directory host per i volumi persistenti
- `all`: Crea directory dati e avvia tutti i servizi con build
- `down`: Ferma tutti i container mantenendo dati
- `re`: Esegue pulizia completa + riavvio
- `fclean`: Rimuove tutto (container, volumi, immagini, dati)
- `logs`: Mostra log in tempo reale di tutti i servizi
- `status`: Mostra stato attuale dei container

### 2. File .env

```bash
# Dominio principale del progetto
DOMAIN_NAME=stefanodipuma.42.fr

# Configurazione database MariaDB
MARIADB_DATABASE=wordpress       # Nome database WordPress
MARIADB_USER=wpuser             # Utente database (non-admin)
# Le password sono gestite tramite Docker secrets per sicurezza
```

**Spiegazione:**
- `DOMAIN_NAME`: Dominio che punta all'infrastruttura locale
- `MARIADB_DATABASE`: Nome del database che conterrà i dati WordPress
- `MARIADB_USER`: Utente normale per WordPress (non amministratore)
- Password: Gestite separatamente via Docker secrets

### 3. Docker Secrets

#### secrets/db_password.txt
```
wppass
```

#### secrets/db_root_password.txt
```
rootpass
```

#### secrets/credentials.txt
```
wpuser:wppass
```

**Scopo**: I Docker secrets permettono di gestire informazioni sensibili senza includerle nel codice o nelle variabili d'ambiente visibili.

---

## SERVIZI OBBLIGATORI

### 1. NGINX - Web Server con TLS

#### Dockerfile
```dockerfile
# Usa Debian Bullseye come base stabile
FROM debian:bullseye

# Installa Nginx e OpenSSL per certificati TLS
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Crea directory per certificati SSL
RUN mkdir -p /etc/nginx/ssl

# Genera certificato SSL auto-firmato per sviluppo
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=DE/ST=Berlin/L=Berlin/O=42School/CN=stefanodipuma.42.fr"

# Copia configurazione personalizzata Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Espone porte HTTP e HTTPS
EXPOSE 80 443

# Avvia Nginx in foreground (necessario per Docker)
CMD ["nginx", "-g", "daemon off;"]
```

#### conf/nginx.conf
```nginx
# Configurazione utente e processi
user www-data;
worker_processes auto;      # Usa tutti i core CPU disponibili
pid /run/nginx.pid;

# Configurazione eventi
events {
    worker_connections 768;  # Connessioni simultanee per worker
    use epoll;              # Metodo efficiente per Linux
}

http {
    # Ottimizzazioni performance
    sendfile on;            # Trasferimento file efficiente
    tcp_nopush on;          # Ottimizza invio pacchetti TCP
    tcp_nodelay on;         # Riduce latenza
    keepalive_timeout 65;   # Timeout connessioni persistenti
    
    # Configurazione MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Compressione Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    # Redirect HTTP -> HTTPS
    server {
        listen 80;
        listen [::]:80;
        server_name stefanodipuma.42.fr;
        return 301 https://$server_name$request_uri;
    }
    
    # Server HTTPS principale
    server {
        # Configurazione SSL/TLS
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name stefanodipuma.42.fr;
        
        # Certificati SSL
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        
        # Configurazione SSL sicura
        ssl_protocols TLSv1.2 TLSv1.3;          # Solo protocolli sicuri
        ssl_prefer_server_ciphers off;           # Usa cifrari client moderni
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
        
        # Security headers
        add_header X-Frame-Options DENY;                    # Previene clickjacking
        add_header X-Content-Type-Options nosniff;          # Previene MIME sniffing
        add_header X-XSS-Protection "1; mode=block";        # Protezione XSS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
        
        # Document root WordPress
        root /var/www/html;
        index index.php index.html index.htm;
        
        # Gestione file PHP via FastCGI
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass wordpress:9000;           # Indirizza a container WordPress
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Gestione file statici
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        
        # Sicurezza: blocca accesso a file sensibili
        location ~ /\.ht {
            deny all;
        }
        
        location ~ /\.git {
            deny all;
        }
    }
}
```

**Spiegazione dettagliata:**

1. **Configurazione base**: Nginx viene configurato per usare tutti i core CPU disponibili
2. **SSL/TLS**: Generazione automatica di certificati auto-firmati per sviluppo
3. **Redirect HTTPS**: Tutto il traffico HTTP viene reindirizzato a HTTPS
4. **Security headers**: Implementazione di header di sicurezza standard
5. **FastCGI**: Configurazione per comunicare con PHP-FPM del container WordPress
6. **Performance**: Ottimizzazioni per gzip, sendfile, e keep-alive

### 2. WORDPRESS - CMS con PHP-FPM

#### Dockerfile
```dockerfile
# Base Debian Bullseye stabile
FROM debian:bullseye

# Installa PHP-FPM e estensioni necessarie per WordPress
RUN apt-get update && \
    apt-get install -y \
        php \
        php-fpm \
        php-mysql \        # Estensione MySQL/MariaDB
        php-curl \         # Per HTTP requests
        php-gd \           # Per manipolazione immagini
        php-xml \          # Per XML parsing
        php-mbstring \     # Per supporto multi-byte string
        php-zip \          # Per gestione file ZIP
        wget && \          # Per download WordPress
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Crea directory per WordPress e scarica ultima versione
RUN mkdir -p /var/www/html && \
    wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

# Copia configurazione WordPress personalizzata
COPY ./tools/wp-config.php /var/www/html/wp-config.php

# Configura PHP-FPM per accettare connessioni TCP invece di socket Unix
RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|g' /etc/php/*/fpm/pool.d/www.conf

# Crea directory runtime per PHP-FPM
RUN mkdir -p /run/php

# Espone porta PHP-FPM
EXPOSE 9000

# Avvia PHP-FPM in foreground
CMD ["php-fpm7.4", "--nodaemonize"]
```

#### tools/wp-config.php
```php
<?php
// Configurazione database WordPress con Docker secrets
define('DB_NAME', 'wordpress');                                    // Nome database
define('DB_USER', 'wpuser');                                      // Utente database
define('DB_PASSWORD', trim(file_get_contents('/run/secrets/db_password'))); // Password da secret
define('DB_HOST', 'mariadb');                                     // Hostname container MariaDB
define('DB_CHARSET', 'utf8');                                     // Charset database
define('DB_COLLATE', '');                                         // Collation database

// Chiavi di sicurezza WordPress (da generare per produzione)
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');

// Prefisso tabelle database
$table_prefix = 'wp_';

// Modalità debug (disabilitata per produzione)
define('WP_DEBUG', false);

// Path assoluto WordPress
if ( !defined('ABSPATH') ) 
    define('ABSPATH', dirname(__FILE__) . '/');

// Carica file di configurazione WordPress
require_once(ABSPATH . 'wp-settings.php');
?>
```

**Caratteristiche implementate:**

1. **Docker Secrets**: La password viene letta dal file secret montato in `/run/secrets/`
2. **PHP-FPM TCP**: Configurato per comunicare via TCP invece di socket Unix
3. **Estensioni PHP**: Tutte le estensioni necessarie per WordPress
4. **Sicurezza**: Configurazione per produzione con debug disabilitato

### 3. MARIADB - Database

#### Dockerfile
```dockerfile
# Base Debian Bullseye
FROM debian:bullseye

# Installa MariaDB server e client
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia file di configurazione personalizzati
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-db.sh /usr/local/bin/init-db.sh

# Rende eseguibile lo script di inizializzazione
RUN chmod +x /usr/local/bin/init-db.sh

# Crea directory e imposta permessi per MariaDB
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /etc/mysql/

# Espone porta standard MySQL/MariaDB
EXPOSE 3306

# Esegui come utente mysql per sicurezza
USER mysql

# Avvia script di inizializzazione
CMD ["/usr/local/bin/init-db.sh"]
```

#### conf/50-server.cnf
```ini
[mysqld]
# Configurazione utente e binding
user                    = mysql
bind-address            = 0.0.0.0        # Accetta connessioni da qualsiasi IP
port                    = 3306
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
skip-external-locking

# Configurazioni di sicurezza
skip-name-resolve                        # Disabilita risoluzione DNS
skip-networking         = false          # Abilita connessioni di rete

# Set di caratteri UTF-8
character-set-server    = utf8mb4
collation-server        = utf8mb4_general_ci

# Logging
log_error               = /var/log/mysql/error.log

# Configurazioni performance
max_connections         = 100            # Massimo connessioni simultanee
connect_timeout         = 60             # Timeout connessione
wait_timeout            = 600            # Timeout inattività
max_allowed_packet      = 16M            # Dimensione massima pacchetti
thread_cache_size       = 128            # Cache thread
sort_buffer_size        = 4M             # Buffer ordinamento
bulk_insert_buffer_size = 16M            # Buffer inserimenti bulk
tmp_table_size          = 32M            # Dimensione tabelle temporanee
max_heap_table_size     = 32M            # Dimensione massima tabelle heap

# Query cache per performance
query_cache_limit       = 128K           # Limite singola query cache
query_cache_size        = 64M            # Dimensione totale query cache
query_cache_type        = ON             # Abilita query cache

# Configurazioni InnoDB storage engine
default-storage-engine  = innodb
innodb_buffer_pool_size = 256M           # Pool buffer InnoDB
innodb_log_buffer_size  = 8M             # Buffer log InnoDB
innodb_file_per_table   = 1              # File separato per tabella
innodb_open_files       = 400            # File aperti simultaneamente
innodb_io_capacity      = 400            # Capacità I/O
innodb_flush_method     = O_DIRECT       # Metodo flush diretto
```

#### tools/init-db.sh
```bash
#!/bin/bash

# Inizializza database MariaDB se directory dati è vuota
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Avvia MariaDB in background per configurazione
mysqld --user=mysql &
MYSQL_PID=$!

# Attende che MariaDB sia pronto
echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB started successfully"

# Legge password dai Docker secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Configura database, utenti e sicurezza
mysql -u root << EOF
-- Imposta password root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Rimuove utenti anonimi per sicurezza
DELETE FROM mysql.user WHERE User='';

-- Rimuove accesso root remoto (eccetto connessioni necessarie)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Rimuove database di test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Crea database WordPress con charset UTF-8
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Crea utente WordPress normale
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';

-- Crea utente WordPress amministratore (nome non contiene 'admin')
CREATE USER IF NOT EXISTS 'wpmanager'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpmanager'@'%';

-- Applica modifiche privilegi
FLUSH PRIVILEGES;
EOF

echo "Database and users created successfully"

# Ferma MariaDB background
kill $MYSQL_PID
wait $MYSQL_PID

echo "Starting MariaDB in foreground..."
# Avvia MariaDB in foreground per Docker
exec mysqld --user=mysql
```

**Funzionalità implementate:**

1. **Inizializzazione automatica**: Crea database e utenti al primo avvio
2. **Sicurezza**: Rimuove utenti anonimi e database di test
3. **Due utenti**: `wpuser` (normale) e `wpmanager` (admin, senza parole vietate)
4. **Docker Secrets**: Password lette da file sicuri
5. **Performance**: Configurazioni ottimizzate per WordPress

---

## SERVIZI BONUS

### 1. REDIS - Cache per WordPress

#### Dockerfile
```dockerfile
FROM debian:bullseye

# Installa Redis server
RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia configurazione Redis personalizzata
COPY conf/redis.conf /etc/redis/redis.conf

# Imposta proprietario file configurazione
RUN chown redis:redis /etc/redis/redis.conf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]
```

#### conf/redis.conf
```ini
# Configurazione rete Redis
bind 0.0.0.0                    # Accetta connessioni da qualsiasi IP
port 6379                       # Porta standard Redis
protected-mode no               # Disabilita modalità protetta per Docker

# Configurazioni generali
daemonize no                    # Non eseguire come daemon (per Docker)
supervised no                   # Non supervisionato da init system
loglevel notice                 # Livello logging
logfile ""                      # Log su stdout per Docker

# Persistenza (disabilitata per cache)
save ""                         # Disabilita salvataggio automatico
appendonly no                   # Disabilita AOF (Append Only File)

# Gestione memoria
maxmemory 256mb                 # Limite memoria massima
maxmemory-policy allkeys-lru    # Policy rimozione chiavi (Least Recently Used)

# Sicurezza
requirepass redispass           # Password accesso Redis

# Gestione client
timeout 300                     # Timeout connessioni client
tcp-keepalive 300              # Keep-alive TCP
tcp-backlog 511                # Backlog connessioni TCP

# Performance
databases 16                    # Numero database disponibili
maxclients 10000               # Massimo client simultanei
```

### 2. FTP SERVER - Gestione file WordPress

#### Dockerfile
```dockerfile
FROM debian:bullseye

# Installa vsftpd (Very Secure FTP Daemon)
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia configurazioni FTP
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup-ftp.sh /usr/local/bin/setup-ftp.sh

RUN chmod +x /usr/local/bin/setup-ftp.sh

# Crea directory FTP
RUN mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /var/ftp && \
    chmod 755 /var/ftp

# Espone porte FTP: controllo (21) e dati passivi (21000-21010)
EXPOSE 21 20 21000-21010

CMD ["/usr/local/bin/setup-ftp.sh"]
```

#### conf/vsftpd.conf
```ini
# Configurazioni base vsftpd
listen=YES                      # Ascolta connessioni IPv4
listen_ipv6=NO                 # Disabilita IPv6
anonymous_enable=NO             # Disabilita accesso anonimo
local_enable=YES                # Abilita utenti locali
write_enable=YES                # Abilita scrittura
dirmessage_enable=YES           # Abilita messaggi directory
use_localtime=YES               # Usa orario locale
xferlog_enable=YES              # Abilita logging trasferimenti
connect_from_port_20=YES        # Connetti da porta 20 per dati

# Configurazioni chroot (jail utenti)
chroot_local_user=YES           # Limita utenti alla loro home
allow_writeable_chroot=YES      # Permetti chroot scrivibile
local_root=/var/www/html        # Directory root per utenti

# Sicurezza
seccomp_sandbox=NO              # Disabilita sandbox per Docker
hide_ids=YES                    # Nascondi ID proprietari file

# Modalità passiva FTP
pasv_enable=YES                 # Abilita modalità passiva
pasv_min_port=21000            # Porta minima range passivo
pasv_max_port=21010            # Porta massima range passivo
pasv_address=localhost          # Indirizzo per connessioni passive

# Gestione utenti
userlist_enable=YES             # Abilita lista utenti
userlist_file=/etc/vsftpd.userlist  # File lista utenti
userlist_deny=NO                # Lista utenti permessi (non negati)

# Permessi file
local_umask=022                 # Umask per file locali
file_open_mode=0666            # Modalità apertura file
anon_umask=022                 # Umask utenti anonimi

# Logging
xferlog_file=/var/log/vsftpd.log    # File log trasferimenti
xferlog_std_format=YES              # Formato standard log

# Performance
idle_session_timeout=600        # Timeout sessione inattiva
data_connection_timeout=120     # Timeout connessione dati
```

#### tools/setup-ftp.sh
```bash
#!/bin/bash

# Crea utente FTP dedicato
adduser --disabled-password --gecos "" ftpuser
echo "ftpuser:ftppass" | chpasswd

# Aggiunge utente alla lista permessi
echo "ftpuser" > /etc/vsftpd.userlist

# Imposta permessi per accesso file WordPress
chown -R ftpuser:ftpuser /var/www/html
chmod -R 755 /var/www/html

echo "FTP server starting..."
exec vsftpd /etc/vsftpd.conf
```

### 3. ADMINER - Gestione Database Web

#### Dockerfile
```dockerfile
FROM debian:bullseye

# Installa stack web per Adminer
RUN apt-get update && \
    apt-get install -y php php-fpm php-mysql nginx wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Scarica ultima versione Adminer
RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php https://www.adminer.org/latest.php

# Copia configurazioni
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/start-adminer.sh /usr/local/bin/start-adminer.sh

RUN chmod +x /usr/local/bin/start-adminer.sh && \
    chown -R www-data:www-data /var/www/html

# Configura PHP-FPM per TCP
RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|g' /etc/php/*/fpm/pool.d/www.conf && \
    mkdir -p /run/php

EXPOSE 8080

CMD ["/usr/local/bin/start-adminer.sh"]
```

#### tools/start-adminer.sh
```bash
#!/bin/bash

# Avvia PHP-FPM in background
php-fpm7.4 --daemonize

# Avvia Nginx in foreground
echo "Starting Adminer on port 8080..."
exec nginx -g "daemon off;"
```

### 4. WEBSITE - Sito Statico Python/Flask

#### Dockerfile
```dockerfile
FROM debian:bullseye

# Installa Python e pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installa Flask framework
RUN pip3 install flask

# Copia applicazione
COPY src/ /app/
COPY tools/start-website.sh /usr/local/bin/start-website.sh

RUN chmod +x /usr/local/bin/start-website.sh

WORKDIR /app

EXPOSE 5000

CMD ["/usr/local/bin/start-website.sh"]
```

#### src/app.py
```python
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    """Homepage portfolio"""
    return render_template('index.html')

@app.route('/about')
def about():
    """Pagina about"""
    return render_template('about.html')

@app.route('/projects')
def projects():
    """Pagina progetti"""
    return render_template('projects.html')

if __name__ == '__main__':
    # Avvia server Flask
    app.run(host='0.0.0.0', port=5000, debug=False)
```

---

## DOCKER COMPOSE - ORCHESTRAZIONE

### docker-compose.yml completo
```yaml
services:
  # DATABASE SERVICE
  mariadb:
    build: ./requirements/mariadb          # Build da Dockerfile custom
    container_name: mariadb
    restart: always                        # Riavvio automatico
    env_file:
      - .env                              # Carica variabili ambiente
    volumes:
      - mariadb_data:/var/lib/mysql       # Volume persistente dati
    environment:
      MARIADB_DATABASE: ${MARIADB_DATABASE}
      MARIADB_USER: ${MARIADB_USER}
    secrets:                              # Monta Docker secrets
      - db_password
      - db_root_password
    networks:
      - intra                             # Network interno

  # CMS SERVICE  
  wordpress:
    build: ./requirements/wordpress        # Build da Dockerfile custom
    container_name: wordpress
    restart: always
    env_file:
      - .env
    depends_on:                           # Dipende da MariaDB
      - mariadb
    volumes:
      - wordpress_data:/var/www/html      # Volume condiviso con Nginx
    secrets:                              # Monta secrets per database
      - db_password
      - credentials
    networks:
      - intra

  # WEB SERVER SERVICE
  nginx:
    build: ./requirements/nginx           # Build da Dockerfile custom
    container_name: nginx
    restart: always
    ports:                               # Porte esposte su host
      - "80:80"                         # HTTP (redirect HTTPS)
      - "443:443"                       # HTTPS
    volumes:
      - wordpress_data:/var/www/html:ro  # Mount read-only file WordPress
    depends_on:                          # Dipende da WordPress
      - wordpress
    networks:
      - intra

  # BONUS SERVICES
  
  # Cache Redis
  redis:
    build: ./requirements/bonus/redis
    container_name: redis
    restart: always
    networks:
      - intra

  # Server FTP  
  ftp:
    build: ./requirements/bonus/ftp
    container_name: ftp
    restart: always
    ports:
      - "21:21"                         # Porta controllo FTP
      - "21000-21010:21000-21010"       # Range porte passive
    volumes:
      - wordpress_data:/var/www/html    # Accesso file WordPress
    depends_on:
      - wordpress
    networks:
      - intra

  # Gestione database web
  adminer:
    build: ./requirements/bonus/adminer
    container_name: adminer
    restart: always
    ports:
      - "8080:8080"                     # Interfaccia web
    depends_on:
      - mariadb
    networks:
      - intra

  # Sito statico Python
  website:
    build: ./requirements/bonus/website
    container_name: website
    restart: always
    ports:
      - "5000:5000"                     # Server Flask
    networks:
      - intra

# VOLUMI PERSISTENTI
volumes:
  mariadb_data:                         # Dati database
  wordpress_data:                       # File WordPress

# NETWORK
networks:
  intra:                               # Network interno bridge
    driver: bridge

# DOCKER SECRETS
secrets:
  db_password:                          # Password database WordPress
    file: ../secrets/db_password.txt
  db_root_password:                     # Password root MariaDB
    file: ../secrets/db_root_password.txt
  credentials:                          # Credenziali utente
    file: ../secrets/credentials.txt
```

**Spiegazione Docker Compose:**

1. **Services**: Definisce 7 servizi (3 obbligatori + 4 bonus)
2. **Volumes**: Due volumi persistenti per dati database e file WordPress
3. **Networks**: Network bridge interno per comunicazione tra container
4. **Secrets**: Gestione sicura delle password tramite file esterni
5. **Dependencies**: Ordine avvio servizi tramite `depends_on`
6. **Restart policies**: Riavvio automatico in caso di crash

---

## SICUREZZA E BEST PRACTICES

### 1. Docker Secrets
- **Scopo**: Gestire informazioni sensibili senza esporle nel codice
- **Implementazione**: File separati nella directory `secrets/`
- **Mount**: I secrets vengono montati in `/run/secrets/` nei container

### 2. File .dockerignore
Ogni servizio ha un file `.dockerignore` per escludere:
- File sensibili (`.env`, `secrets/`, `*.key`)
- File di sviluppo (`.vscode/`, `.idea/`, `*.log`)
- File temporanei (`*.tmp`, `*.bak`, `*.swp`)
- Documentazione (`README.md`, `docs/`)

### 3. Security Headers Nginx
```nginx
add_header X-Frame-Options DENY;                    # Anti-clickjacking
add_header X-Content-Type-Options nosniff;          # Anti-MIME sniffing
add_header X-XSS-Protection "1; mode=block";        # Protezione XSS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
```

### 4. Configurazioni Database Sicure
- Rimozione utenti anonimi
- Eliminazione database di test
- Restrizione accesso root
- Password complesse via secrets

### 5. Container Non-Root
I container eseguono con utenti dedicati non-privilegiati:
- MariaDB: utente `mysql`
- Redis: utente `redis`
- Nginx: utente `www-data`

---

## COMANDI DI GESTIONE

### Build e Deploy
```bash
# Avvio completo infrastruttura
make all

# Rebuild completo
make re

# Stop servizi
make down

# Pulizia totale
make fclean
```

### Monitoraggio
```bash
# Status container
make status
docker-compose ps

# Log real-time
make logs
docker-compose logs -f [service]

# Accesso shell container
docker exec -it [container] bash

# Verifica risorse
docker stats
```

### Debug
```bash
# Test connettività
curl -k https://localhost
curl http://localhost:8080  # Adminer
curl http://localhost:5000  # Website

# Verifica database
docker exec mariadb mysql -u wpuser -p wordpress

# Test FTP
ftp localhost 21
```

---

## TROUBLESHOOTING

### Problemi Comuni

#### 1. "Cannot connect to Docker daemon"
**Soluzione**: Avviare Docker Desktop su macOS

#### 2. "Port already in use"
**Soluzione**: 
```bash
# Trova processo che usa la porta
lsof -i :443
# Termina processo o cambia porta in docker-compose.yml
```

#### 3. "Database connection error WordPress"
**Possibili cause**:
- MariaDB non ancora pronto
- Password secrets non leggibili
- Network connectivity issues

**Debug**:
```bash
# Verifica status MariaDB
docker logs mariadb

# Test connessione database
docker exec wordpress php -r "
$conn = new mysqli('mariadb', 'wpuser', 'wppass', 'wordpress');
echo $conn->connect_error ? 'Error: '.$conn->connect_error : 'Success!';
"
```

#### 4. "502 Bad Gateway Nginx"
**Possibili cause**:
- PHP-FPM non in ascolto
- WordPress container non pronto
- Configurazione FastCGI errata

**Debug**:
```bash
# Verifica PHP-FPM
docker exec wordpress netstat -tlnp | grep 9000

# Test comunicazione Nginx-WordPress
docker exec nginx ping wordpress
```

#### 5. "SSL Certificate errors"
**Soluzione**: Accettare certificato auto-firmato nel browser o:
```bash
# Rigenerare certificati
docker exec nginx openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=42School/CN=stefanodipuma.42.fr"
```

### Performance Tuning

#### MariaDB Optimization
```ini
# In 50-server.cnf
innodb_buffer_pool_size = 512M    # Aumenta per più RAM
query_cache_size = 128M           # Aumenta per cache query
max_connections = 200             # Aumenta per più utenti
```

#### Nginx Optimization
```nginx
# In nginx.conf
worker_processes auto;            # Usa tutti i core
worker_connections 2048;          # Aumenta connessioni per worker
keepalive_timeout 120;            # Aumenta timeout
```

#### WordPress Optimization
```php
// In wp-config.php
define('WP_CACHE', true);                    // Abilita cache
define('COMPRESS_CSS', true);                // Comprimi CSS
define('COMPRESS_SCRIPTS', true);            // Comprimi JS
define('CONCATENATE_SCRIPTS', true);         // Concatena script
```

---

## CONCLUSIONI

Questa guida copre l'implementazione completa del progetto Inception con:

✅ **Requisiti Obbligatori Completati**:
- Nginx con TLS
- WordPress con PHP-FPM  
- MariaDB con Dockerfile custom
- Docker Compose orchestrazione
- Docker Secrets per sicurezza
- Volumi persistenti
- Network interno

✅ **Bonus Implementati**:
- Redis cache
- FTP server
- Adminer gestione database
- Sito statico Python/Flask

✅ **Best Practices**:
- Sicurezza container
- Configurazioni ottimizzate
- Logging e monitoring
- Documentation completa

Il progetto dimostra competenze avanzate in:
- **Containerizzazione**: Docker multi-stage builds
- **Orchestrazione**: Docker Compose con dependencies
- **Sicurezza**: Secrets management, SSL/TLS, security headers
- **Performance**: Ottimizzazioni database, web server, cache
- **Operations**: Automazione con Makefile, monitoring, troubleshooting

**Per conversione in PDF**: Usa Pandoc o stampa questa guida da un editor Markdown.

**Comando Pandoc**:
```bash
pandoc guida-inception.md -o guida-inception.pdf --pdf-engine=xelatex
```

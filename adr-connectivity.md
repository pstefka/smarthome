# Connectivity

<https://wfd.cloud.cambiumnetworks.com/wfdc/dashboard>
<img width="467" height="430" alt="2026-05-25 12_17_31-Greenshot" src="https://github.com/user-attachments/assets/93afdfae-8775-4ff1-b130-8a9db8a2b531" />
<img width="467" height="430" alt="2026-05-25 12_16_42-Greenshot" src="https://github.com/user-attachments/assets/ee070bab-ca34-4180-9010-ab1e94297c81" />
<img width="467" height="430" alt="2026-05-25 12_24_52-Greenshot" src="https://github.com/user-attachments/assets/63287a7c-f1f3-4aea-a421-2959343d4fbf" />
<img width="467" height="430" alt="2026-05-25 12_22_59-Greenshot" src="https://github.com/user-attachments/assets/866e2ba7-c0fd-4136-b989-08ff82e3aedc" />
<img width="467" height="430" alt="2026-05-25 12_24_05-Greenshot" src="https://github.com/user-attachments/assets/2b0a4421-93d2-49e9-9f48-cd62cf0558c3" />
<img width="467" height="430" alt="2026-05-25 12_22_32-Greenshot" src="https://github.com/user-attachments/assets/2e0a2802-4fa1-446c-b2b7-b26a86c42a26" />
<img width="467" height="430" alt="2026-05-25 12_21_44-Greenshot" src="https://github.com/user-attachments/assets/858cb5e5-ec75-4c00-9469-d35657cef3d8" />
<img width="467" height="430" alt="2026-05-25 12_17_15-Greenshot" src="https://github.com/user-attachments/assets/61db10ef-23e3-4a00-aa67-61a7b7c78164" />
<img width="467" height="430" alt="2026-05-25 12_17_54-Greenshot" src="https://github.com/user-attachments/assets/b7ebcfd6-3f93-44f6-ac9d-3908a05e494f" />



## Digi

```mermaid
flowchart TD


subgraph Flat

  subgraph Study Room
    P1[Provider socket]
    RX[RouterX]
    W2[Wifi]

    P1 -- ethernet --> W2
    W2 -- switch --> RX
  end

  subgraph Living Room
    P2[Provider socket]
    TV

    P2 -- coax --> TV
  end

end
```

## Non Digi

```mermaid
flowchart TD

P[Provider socket]

subgraph Flat

  subgraph Closet Hallway
    ONT
    W1[Wifi]
  end

  subgraph Study Room
    RX[Router X]
    W2[Wifi]
    PC
    HUE

    RX --> W2
    RX --> PC
    RX --> HUE
  end

  subgraph Living Room
    TV
  end

  W1 --> RX
  W1 --> TV

end

P -- optical --> ONT
ONT -- ethernet --> W1
```

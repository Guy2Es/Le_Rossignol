---
name: phase3-regles-utilisateur
description: "Règles de travail de l'utilisateur sur le projet drone (aile volante V1) — MATLAB, chiffres, cahier gelé, arrêts pour décision"
metadata:
  node_type: memory
  type: feedback
  originSessionId: cca9d503-6024-4563-8b98-5645c2e36348
  modified: 2026-10-12T22:04:53.777Z
---

Règles de travail :
- Ne présenter aucun chiffre que MATLAB n'a pas calculé.
- Ne jamais modifier le cahier des charges. Proposer des brouillons de MOD (date, exigence, ancienne et nouvelle valeur, justification).
- Suivre la skill /aircraft-design et signaler les écarts.
- Zéro warning du Code Analyzer ; tous les paramètres dans `params_v1.m`.
- S'arrêter avant les choix structurants (KV moteur) et présenter un classement, sans recommander à la place de l'utilisateur.
- Répondre en français.

**Why:** l'utilisateur est l'ingénieur responsable, et les estimations IA du cahier se sont révélées non vérifiées.

**How to apply:** à chaque phase, proposer un plan, attendre l'accord, exécuter réellement, puis s'arrêter aux points de décision. Voir [[phase3-choix-moteur]].

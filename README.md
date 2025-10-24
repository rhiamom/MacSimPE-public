# MacSimPE — Objective-C Port of SimPE
#### Based on SimPE 0.72.x source code (targeting parity with 0.75f)

![License: GPL v2+](https://img.shields.io/badge/License-GPL_v2%2B-blue.svg)
![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Language: Objective-C](https://img.shields.io/badge/language-Objective-C-green.svg)

---

## Overview

**MacSimPE** is a native macOS re-implementation of **SimPE**, the Sims 2 Package Editor originally developed by **Quaxi** and **Peter Jones**.  
It translates the original C# SimPE 0.72.x codebase into **Objective-C**, with the goal of achieving feature parity with the final stable release, **SimPE 0.75f**.

The purpose of MacSimPE is to provide creators and modders using the **Aspyr Sims 2 Super Collection** with a modern, open-source, and fully Mac-native package editing tool — free of Windows dependencies and built on clean, GPL-compliant code.

---

## Project Goals

- ✅ Preserve legitimate SimPE functionality under macOS  
- ✅ Maintain GPLv2+ license continuity from the original open-source project  
- ✅ Ensure cross-compatibility with the Aspyr **Sims 2 Super Collection**  
- ✅ Support modern high-resolution displays and macOS file handling  
- 🚧 Ongoing work: DBPF parsing, TXTR/TXMT/MMAT editors, and object recolor support  

All development occurs in a **private working repository** (`MacSimPE`) with this read-only mirror provided for transparency, historical record, and community review.

---

## Source Lineage

| Line | Description |
|------|--------------|
| **SimPE 0.72.x (C#)** | Last publicly released open-source version by Quaxi and Peter Jones |
| **SimPE 0.75f** | Final stable Windows release by Quaxi (closed-source binary only) |
| **MacSimPE (Objective-C)** | Clean translation and modernization for macOS by Catherine Gramze |

All adult or non-open content added in later unofficial forks has been deliberately excluded.

---

## Licensing

MacSimPE is licensed under the **GNU General Public License, version 2 or later (GPL-2.0+)**.  
Each source file includes both the original SimPE header and a line noting its Objective-C translation credit.

For full license details, see the `COPYING` file and the [GNU GPL v2 text](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

---

## Credits

- **Quaxi** — Original SimPE creator and core developer  
- **Peter Jones** — Core developer and plugin architect  
- **Catherine Gramze** — Objective-C translation, macOS adaptation, and SimKit integration  

For a complete author list, see [`AUTHORS`](./AUTHORS).

---

## Repository

- **Public mirror (read-only):** [https://github.com/rhiamom/MacSimPE-public](https://github.com/rhiamom/MacSimPE-public)  
- **Private active development:** *MacSimPE (private)*

---

## Contact

Maintainer: **Catherine Gramze**  
Email: `<rhiamom@mac.com>`

---

> *MacSimPE is not affiliated with Electronic Arts, Maxis, or Aspyr Media.  
> “The Sims 2” and related trademarks are property of their respective owners.*

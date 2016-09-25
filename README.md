# Mobbur

![Heroku](http://heroku-badge.herokuapp.com/?app=mobbur&style=flat)

A Proof-of-Concept mob programming timer web app built using Elixir/Phoenix and Elm.

Highly inspired by the [Agility Timer](http://oss.jahed.io/agility/timer.html).

Esthetics may suck.

Working example here: https://mobbur.herokuapp.com/

## Principles

- Should not replace real communication

## Functionality / Roadmap

- [x] Editable countdown timer
- [x] Editable team name
- [x] Editable team members
  - [x] Removable
- [x] Auto-restart of timer (configurable)
- [x] Countdown to timer restart (configurable)
- [x] Active team member (incl. auto-rotation)
- [x] Fast forward active team member
- [ ] Less fugly layout/graphics!

## Running Mobbur

To start Mobbur:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

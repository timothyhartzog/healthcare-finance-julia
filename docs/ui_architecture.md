# UI Architecture

## Overview

The dashboard is built using Genie + Stipple reactive framework.

## Components

- ReactiveModel: stores financial inputs and outputs
- UI Layer: StippleUI components (inputs, outputs, buttons)
- Controller: routes and recalculation logic

## Data Flow

User Input → Reactive Model → Financial Engine → Output Update

## Future Enhancements

- Charts (Makie / Plotly)
- File upload (CSV hospital datasets)
- Multi-scenario comparison
- Authentication for enterprise deployment

# Dice

> ***A dice expression parser/roller for `Elixir`.***

## Syntax Overview

### Basics

Dice expressions let you describe rolling multiple dice of different sizes, and modifying the results. You can:

- Roll dice with any number of sides (`dS`)
- Add or subtract a constant value from the results (`dS ± C`)
- Roll multiple dice with the same number of sides and add their results together as a pool (`NdS`)
- Add or subtract multiple pools and constants together (`NdS + MdT + C`)

| Operation | Expression | Interpretation | Example | Meaning | Notes |
| :---: | ---: | :--- | ---: | :--- | :--- |
| ***Roll*** | `dS` | Roll a die with `S` sides  | `d20` | Roll 1 `d20` | Equivalent to ***Roll Many***: `1dS`
| ***Addition*** | `dS + C` | Roll `N` dice with `S` sides, and add a constant value `C` from the result  | `d20 + 5` | Roll 1 `d20` and add `5` to the result |
| ***Subtraction*** | `dS - C` | Roll `N` dice with `S` sides, and subtract a constant value `C` from the result  | `d20 - 2` | Roll 1 `d20` and subtract `2` from the result |
| ***Roll Many*** | `NdS` | Roll `N` dice with `S` sides and add the results  | `3d6` | Roll 3 `d6` and add the results |
| ***Roll Different*** | `NdS + MdT + C` | Roll `N` dice with `S` sides, `M` dice with `T` sides, and add all together plus `C`  | `3d6 + d4 + 2` | Roll 3 `d6`, one `d4`, and add `2` to the results |

### Roll Modifiers

Roll modifiers let you describe rolling a pool of dice, and doing something with the results before factoring them into the calculation. Multiple modifiers stack, and are applied in order.

#### Keep

***Keep*** (`K`) lets you only hold on to certain dice in a pool before adding them together.

By default, random dice are kept. This can be further modified to:

- Keep the highest rolls (***Keep Highest***: `KH`)
- Keep the lowest rolls (***Keep Lowest***: `KL`)
- Explicitly keep random rolls ***Keep Random***: (`KR`)

| Operation | Expression | Interpretation | Example | Meaning | Notes |
| :---: | ---: | :--- | ---: | :--- | :--- |
| ***Keep*** | `NdSK` | Roll `N` dice with `S` sides, and keep a random die  | `2d20K` | Roll 2 `d20` and keep one at random | Equivalent to ***Keep Random***: `NdSK1R` |
| ***Keep Many*** | `NdSKM` | Roll `N` dice with `S` sides, and keep `M` random dice  | `3d20K2` | Roll 3 `d20` and keep `2` at random | Equivalent to ***Keep Random***: `NdSKMR` |
| ***Keep Random*** | `NdSKMR` | Roll `N` dice with `S` sides, and keep `M` random dice  | `3d20K2R` | Roll 3 `d20` and keep `2` at random | Equivalent to ***Keep Many***: `NdSKM` |
| ***Keep Highest*** | `NdSKH` | Roll `N` dice with `S` sides, and keep the highest result  | `2d20KH` | Roll 2 `d20` and keep the highest result |  |
| ***Keep High*** | `NdSKMH` | Roll `N` dice with `S` sides, and keep the highest `M` results  | `3d20K2H` | Roll 3 `d20` and keep the `2` highest |  |
| ***Keep Lowest*** | `NdSKL` | Roll `N` dice with `S` sides, and keep the lowest result  | `2d20KL` | Roll 2 `d20` and keep the lowest result |  |
| ***Keep Low*** | `NdSKML` | Roll `N` dice with `S` sides, and keep the lowest `M` results  | `3d20K2L` | Roll 3 `d20` and keep the `2` lowest |  |

#### Drop

***Drop*** (`D`) lets you discard certain dice from a pool before adding them together.

By default, random dice are dropped. This can be further modified to:

- Drop the highest rolls (***Drop Highest***: `DH`)
- Drop the lowest rolls (***Drop Lowest***: `DL`)
- Explicitly drop random rolls (***Drop Random***: `DR`)

| Operation | Expression | Interpretation | Example | Meaning | Notes |
| :---: | ---: | :--- | ---: | :--- | :--- |
| ***Drop*** | `NdSD` | Roll `N` dice with `S` sides, and drop a random die  | `2d20D` | Roll 2 `d20` and drop one at random | Equivalent to ***Drop Random***: `NdSD1R` |
| ***Drop Many*** | `NdSDM` | Roll `N` dice with `S` sides, and drop `M` random dice  | `3d20D2` | Roll 3 `d20` and drop `2` at random | Equivalent to ***Drop Random***: `NdSDMR` ||
| ***Drop Random*** | `NdSDMR` | Roll `N` dice with `S` sides, and drop `M` random dice  | `3d20D2R` | Roll 3 `d20` and drop `2` at random | Equivalent to ***Drop Many***: `NdSKM` | 
| ***Drop Highest*** | `NdSDH` | Roll `N` dice with `S` sides, and drop the highest result  | `2d20DH` | Roll 2 `d20` and drop the highest result |  |
| ***Drop High*** | `NdSDMH` | Roll `N` dice with `S` sides, and drop the highest `M` results  | `3d20D2H` | Roll 3 `d20` and drop the `2` highest |
| ***Drop Lowest*** | `NdSDL` | Roll `N` dice with `S` sides, and drop the lowest result  | `2d20DL` | Roll 2 `d20` and drop the lowest result |  |
| ***Drop Low*** | `NdSDML` | Roll `N` dice with `S` sides, and drop the lowest `M` results  | `3d20D2L` | Roll 3 `d20` and drop the `2` lowest |  |

#### Explode

Explode (`!`) lets you roll extra dice in a pool before adding them together.

By default, only the maximum possible roll triggers an explosion. This can be further modified by providing an explicit threshold at which to explode (***Explode At***: `!N`).

By default, an explosion adds another die of the same sides to the pool. This can be further modified by specifying a die to explode with (***Explode With***: `!dT`)

By default, re-rolls do not trigger explosions.. This can be further modified by specifying that re-rolls can keep exploding (***Keep Exploding***: `!!`, ***Keep Exploding At***: `!!N`).

***Keep Exploding*** (`!!`) will not explode on 1-sided dice rolls. ***Keep Exploding At*** (`!!N`) will not keep exploding dice where no side is greater than `N`.

| Operation | Expression | Interpretation | Example | Meaning | Notes |
| :---: | ---: | :--- | ---: | :--- | :--- |
| ***Explode*** | `dS!` | Roll one die with `S` sides, and if the die rolls `S`, roll another `dS` to the pool. | `d20!` | Roll one `d20` and add another `d20` roll to the pool if the first rolls `20` | Equivalent to ***Explode At***: `dS!S` |
| ***Explode At*** | `dS!N` | Roll one die with `S` sides, and if the die rolls higher than or equal to `N`, roll another `dS` to the pool  | `d20!18` | Roll one `d20` and add another `d20` roll to the pool if the first rolls `18` or higher |  |
| ***Explode With*** | `dS!dT` | Roll one die with `S` sides, and if the die rolls higher than or equal to `N`, roll a `dT` to the pool  | `d20!d4` | Roll one `d20` and add a `d4` roll to the pool if the first rolls `20` |  |

#### Maximize

Maximize (`M`) lets you see what the maximum possible roll for a pool would be in a pool before adding them together.

By default, only the maximum possible roll triggers an explosion. This can be further modified by providing an explicit threshold at which to explode (***Explode At***: `!N`).

By default, an explosion adds another die of the same sides to the pool. This can be further modified by specifying a die to explode with (***Explode With***: `!dT`)

By default, re-rolls do not trigger explosions.. This can be further modified by specifying that re-rolls can keep exploding (***Keep Exploding***: `!!`, ***Keep Exploding At***: `!!N`).

***Keep Exploding*** (`!!`) will not explode on 1-sided dice rolls. ***Keep Exploding At*** (`!!N`) will not keep exploding dice where no side is greater than `N`.

| Operation | Expression | Interpretation | Example | Meaning | Notes |
| :---: | ---: | :--- | ---: | :--- | :--- |
| ***Explode*** | `dS!` | Roll one die with `S` sides, and if the die rolls `S`, roll another `dS` to the pool. | `d20!` | Roll one `d20` and add another `d20` roll to the pool if the first rolls `20` | Equivalent to ***Explode At***: `dS!S` |
| ***Explode At*** | `dS!N` | Roll one die with `S` sides, and if the die rolls higher than or equal to `N`, roll another `dS` to the pool  | `d20!18` | Roll one `d20` and add another `d20` roll to the pool if the first rolls `18` or higher |  |
| ***Explode With*** | `dS!dT` | Roll one die with `S` sides, and if the die rolls higher than or equal to `N`, roll a `dT` to the pool  | `d20!d4` | Roll one `d20` and add a `d4` roll to the pool if the first rolls `20` |  |

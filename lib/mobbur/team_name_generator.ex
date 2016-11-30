defmodule Mobbur.TeamNameGenerator do

  @prefixen ["Furious",
             "Awesome",
             "Fearsome",
             "Inglorious",
             "Obsequious",
             "Obnoxious",
             "Performing",
             "Storming",
             "Red",
             "Valorous"
            ]

  @suffixen ["Anonymous",
             "Foosome",
             "Multipliers",
             "Calculators",
             "Egg Heads",
             "Brainiacs",
             "Nonames",
             "Nomads",
             "Tribals",
             "Pencil Pushers",
             "Herrings",
             "Elderberries"
            ]

  def generate_name() do
    prefix = Enum.random @prefixen
    suffix = Enum.random @suffixen
    "#{prefix} #{suffix}"
  end


end

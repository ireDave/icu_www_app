module TournamentsHelper
  def tournament_category_menu(selected, default="tournament.category.any")
    cats = Tournament::CATEGORIES.map { |cat| [t("tournament.category.#{cat}"), cat] }
    cats.unshift [t(default), ""]
    options_for_select(cats, selected)
  end

  def tournament_format_menu(selected, default="tournament.format.any")
    fmts = Tournament::FORMATS.map { |fmt| [t("tournament.format.#{fmt}"), fmt] }
    fmts.unshift [t(default), ""]
    options_for_select(fmts, selected)
  end
end

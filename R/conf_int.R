#' Compute the confidence interval for (currently only) simulation-based methods
#' 
#' \code{get_confidence_interval()} and \code{get_ci()} are both aliases of \code{conf_int()}
#' @param x data frame of calculated statistics or containing attributes
#' of theoretical distribution values. Currently, dependent on statistics being stored in \code{stat} column as created in \code{calculate()} function.
#' @param level a numerical value between 0 and 1 giving the confidence level. Default value is 0.95.
#' @param type a string giving which method should be used for creating the confidence interval. The default is \code{"percentile"} with \code{"se"} corresponding to (2 * standard error) as the other option.
#' @param point_estimate a numeric value or a 1x1 data frame set to NULL by default. Needed to be provided if \code{type = "se"}.
#'
#' @return a 2 x 1 tibble with values corresponding to lower and upper values in the confidence interval
#' @export
#' @rdname get_ci
#' @examples
#' mtcars_df <- mtcars %>%
#'     dplyr::mutate(am = factor(am))
#' d_hat <- mtcars_df %>%
#'     specify(mpg ~ am) %>%
#'     calculate(stat = "diff in means", order = c("1", "0"))
#' bootstrap_distn <- mtcars_df %>%
#'     specify(mpg ~ am) %>%
#'     generate(reps = 100) %>%
#'    calculate(stat = "diff in means", order = c("1", "0"))
#' bootstrap_distn %>% conf_int(level = 0.9)
#' bootstrap_distn %>% conf_int(type = "se", point_estimate = d_hat)

conf_int <- function(x, level = 0.95, type = "percentile", 
                     point_estimate = NULL){
  
  check_ci_args(x, level, type, point_estimate)
  
  if(type == "percentile") {
    ci_vec <- stats::quantile(x[["stat"]], 
                      probs = c((1 - level) / 2, level + (1 - level) / 2))
  
    ci <- tibble::tibble(ci_vec[1], ci_vec[2])
    names(ci) <- names(ci_vec)
  } else {
    point_estimate <- check_obs_stat(point_estimate)
    multiplier <- stats::qnorm(1 - (1 - level) / 2)
    ci <- tibble::tibble(
      lower = point_estimate - multiplier * stats::sd(x[["stat"]]),
      upper = point_estimate + multiplier * stats::sd(x[["stat"]]))
  }
  
  return(ci)
}

check_ci_args <- function(x, level, type, point_estimate){
  
  if(!is.null(point_estimate)){
    if(!is.data.frame(point_estimate))
      assertive::assert_is_numeric(point_estimate)
    else
      assertive::assert_is_data.frame(point_estimate)
  }
  assertive::assert_is_data.frame(x)
  assertive::assert_is_numeric(level)
  if(level <= 0 || level >= 1){
    stop(paste("The value of `level` must be between 0 and 1", 
                  "non-inclusive."))
  }
  
  if(!(type %in% c("percentile", "se"))){
    stop(paste('The options for `type` are "percentile" or "se".'))
  }

  if(type == "se" && is.null(point_estimate))
    stop(paste('A numeric value needs to be given for `point_estimate`',
               'for `type = "se"'))

  if(type == "se" && is.vector(point_estimate))
    assertive::assert_is_numeric(point_estimate)
}


#' @export
#' @rdname get_ci

get_ci <- conf_int

#' @export
#' @rdname get_ci

get_confidence_interval <- conf_int

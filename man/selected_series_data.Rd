% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers.R
\name{selected_series_data}
\alias{selected_series_data}
\title{Filter race data by series}
\usage{
selected_series_data(series)
}
\arguments{
\item{series}{A string specifying the race series ('cup', 'xfinity', 'truck',
or 'all').}
}
\value{
A filtered data frame of \code{class()} "tbl_df" containing race results
for the specified series.
}
\description{
Internal helper function to filter race data based on the specified series.
}
\keyword{internal}

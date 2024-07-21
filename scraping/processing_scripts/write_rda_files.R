library(tidyverse)
library(glue)

to_path <- '../data/data'

series <- list('cup', 'xfinity', 'truck')

for (i in series) {
    print(i)
    # List of your CSV files
    csv_files <- list.files(
        glue::glue(
            'data/{i}-series/cleaned', pattern = "*.csv", full.names = TRUE
        )
    )
    for (j in csv_files) {
        print(j)
        base_name <- tools::file_path_sans_ext(basename(j))
        print(base_name)

        data <- read_csv(
            glue::glue(
                'data/{i}-series/cleaned/{j}'
            )
        )

        assign(base_name, data)

        save(
            list = base_name, 
            file = glue::glue('{to_path}/{base_name}.rda'),
            compress = 'xz'
        )

        rm(data)
    }
}

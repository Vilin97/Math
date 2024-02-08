using DataFrames, CSV, Statistics

#read csv from data/Data.csv
path = joinpath("data", "Data.csv")
df = DataFrame(CSV.File(path))

function missing_parse(T, s)
    val = tryparse(T, s)
    isnothing(val) ? missing : val
end

# parse strings into floats and NaNs in case of NA
for col in names(df)
    df[!, col] = missing_parse.(Float64, df[!, col])
end

# find missing values
missing_df = deepcopy(df)
for col in names(missing_df)
    missing_df[!, col] = ismissing.(missing_df[!, col])
end

# impute missing values with the mean of the column
imputeded_df = deepcopy(df)
for col in names(imputeded_df)
    mean_val = mean(skipmissing(imputeded_df[!, col]))
    imputeded_df[!, col] = coalesce.(imputeded_df[!, col], mean_val)
end

function make_submission(imputeded_df, missing_df)
    submission = DataFrame(CSV.File(joinpath("data", "sample_submission.csv")))
    counter = 1
    for i in 1:size(imputeded_df, 1), j in 1:size(imputeded_df, 2)
        !missing_df[i, j] && continue
        submission[counter, 2] = imputeded_df[i, j]
        counter += 1
    end
    return submission
end
CSV.write(joinpath("data", "submission.csv"), make_submission(imputeded_df, missing_df))
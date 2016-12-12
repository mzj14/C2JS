; ModuleID = 'level_2.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [83 x i8] c"Please enter a source string less than 100 character, terminated by an enter key:\0A\00", align 1
@.str.1 = private unnamed_addr constant [83 x i8] c"Please enter a target string less than 100 character, terminated by an enter key:\0A\00", align 1
@.str.2 = private unnamed_addr constant [4 x i8] c"%d \00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"False\00", align 1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %source = alloca [100 x i8], align 16
  %target = alloca [100 x i8], align 16
  %source_len = alloca i32, align 4
  %target_len = alloca i32, align 4
  %k = alloca i32, align 4
  %z = alloca i32, align 4
  %next_pose = alloca [100 x i32], align 16
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %flag = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([83 x i8], [83 x i8]* @.str, i32 0, i32 0))
  %3 = getelementptr inbounds [100 x i8], [100 x i8]* %source, i32 0, i32 0
  %4 = call i32 (i8*, ...) bitcast (i32 (...)* @gets to i32 (i8*, ...)*)(i8* %3)
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([83 x i8], [83 x i8]* @.str.1, i32 0, i32 0))
  %6 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i32 0, i32 0
  %7 = call i32 (i8*, ...) bitcast (i32 (...)* @gets to i32 (i8*, ...)*)(i8* %6)
  %8 = getelementptr inbounds [100 x i8], [100 x i8]* %source, i32 0, i32 0
  %9 = call i64 @strlen(i8* %8)
  %10 = trunc i64 %9 to i32
  store i32 %10, i32* %source_len, align 4
  %11 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i32 0, i32 0
  %12 = call i64 @strlen(i8* %11)
  %13 = trunc i64 %12 to i32
  store i32 %13, i32* %target_len, align 4
  store i32 -1, i32* %k, align 4
  store i32 0, i32* %z, align 4
  %14 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 0
  store i32 -1, i32* %14, align 16
  br label %15

; <label>:15                                      ; preds = %48, %0
  %16 = load i32, i32* %z, align 4
  %17 = load i32, i32* %target_len, align 4
  %18 = icmp slt i32 %16, %17
  br i1 %18, label %19, label %49

; <label>:19                                      ; preds = %15
  %20 = load i32, i32* %k, align 4
  %21 = icmp eq i32 %20, -1
  br i1 %21, label %34, label %22

; <label>:22                                      ; preds = %19
  %23 = load i32, i32* %z, align 4
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %24
  %26 = load i8, i8* %25, align 1
  %27 = sext i8 %26 to i32
  %28 = load i32, i32* %k, align 4
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %29
  %31 = load i8, i8* %30, align 1
  %32 = sext i8 %31 to i32
  %33 = icmp eq i32 %27, %32
  br i1 %33, label %34, label %43

; <label>:34                                      ; preds = %22, %19
  %35 = load i32, i32* %k, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %k, align 4
  %37 = load i32, i32* %z, align 4
  %38 = add nsw i32 %37, 1
  store i32 %38, i32* %z, align 4
  %39 = load i32, i32* %k, align 4
  %40 = load i32, i32* %z, align 4
  %41 = sext i32 %40 to i64
  %42 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %41
  store i32 %39, i32* %42, align 4
  br label %48

; <label>:43                                      ; preds = %22
  %44 = load i32, i32* %k, align 4
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %45
  %47 = load i32, i32* %46, align 4
  store i32 %47, i32* %k, align 4
  br label %48

; <label>:48                                      ; preds = %43, %34
  br label %15

; <label>:49                                      ; preds = %15
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %flag, align 4
  br label %50

; <label>:50                                      ; preds = %49, %97
  br label %51

; <label>:51                                      ; preds = %86, %50
  %52 = load i32, i32* %i, align 4
  %53 = load i32, i32* %source_len, align 4
  %54 = icmp slt i32 %52, %53
  br i1 %54, label %55, label %59

; <label>:55                                      ; preds = %51
  %56 = load i32, i32* %j, align 4
  %57 = load i32, i32* %target_len, align 4
  %58 = icmp slt i32 %56, %57
  br label %59

; <label>:59                                      ; preds = %55, %51
  %60 = phi i1 [ false, %51 ], [ %58, %55 ]
  br i1 %60, label %61, label %87

; <label>:61                                      ; preds = %59
  %62 = load i32, i32* %j, align 4
  %63 = icmp eq i32 %62, -1
  br i1 %63, label %76, label %64

; <label>:64                                      ; preds = %61
  %65 = load i32, i32* %i, align 4
  %66 = sext i32 %65 to i64
  %67 = getelementptr inbounds [100 x i8], [100 x i8]* %source, i64 0, i64 %66
  %68 = load i8, i8* %67, align 1
  %69 = sext i8 %68 to i32
  %70 = load i32, i32* %j, align 4
  %71 = sext i32 %70 to i64
  %72 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %71
  %73 = load i8, i8* %72, align 1
  %74 = sext i8 %73 to i32
  %75 = icmp eq i32 %69, %74
  br i1 %75, label %76, label %81

; <label>:76                                      ; preds = %64, %61
  %77 = load i32, i32* %i, align 4
  %78 = add nsw i32 %77, 1
  store i32 %78, i32* %i, align 4
  %79 = load i32, i32* %j, align 4
  %80 = add nsw i32 %79, 1
  store i32 %80, i32* %j, align 4
  br label %86

; <label>:81                                      ; preds = %64
  %82 = load i32, i32* %j, align 4
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %83
  %85 = load i32, i32* %84, align 4
  store i32 %85, i32* %j, align 4
  br label %86

; <label>:86                                      ; preds = %81, %76
  br label %51

; <label>:87                                      ; preds = %59
  %88 = load i32, i32* %j, align 4
  %89 = load i32, i32* %target_len, align 4
  %90 = icmp eq i32 %88, %89
  br i1 %90, label %91, label %96

; <label>:91                                      ; preds = %87
  %92 = load i32, i32* %i, align 4
  %93 = load i32, i32* %target_len, align 4
  %94 = sub nsw i32 %92, %93
  %95 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i32 0, i32 0), i32 %94)
  store i32 1, i32* %flag, align 4
  store i32 0, i32* %j, align 4
  br label %97

; <label>:96                                      ; preds = %87
  br label %98

; <label>:97                                      ; preds = %91
  br label %50

; <label>:98                                      ; preds = %96
  %99 = load i32, i32* %flag, align 4
  %100 = icmp eq i32 %99, 0
  br i1 %100, label %101, label %103

; <label>:101                                     ; preds = %98
  %102 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.3, i32 0, i32 0))
  br label %103

; <label>:103                                     ; preds = %101, %98
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

declare i32 @gets(...) #1

declare i64 @strlen(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}

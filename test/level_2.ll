; ModuleID = 'test/level_2.c'
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
  %9 = call i64 @strlen(i8* %8) #3
  %10 = trunc i64 %9 to i32
  store i32 %10, i32* %source_len, align 4
  %11 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i32 0, i32 0
  %12 = call i64 @strlen(i8* %11) #3
  %13 = trunc i64 %12 to i32
  store i32 %13, i32* %target_len, align 4
  store i32 -1, i32* %k, align 4
  store i32 0, i32* %z, align 4
  %14 = load i32, i32* %k, align 4
  %15 = load i32, i32* %z, align 4
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %16
  store i32 %14, i32* %17, align 4
  br label %18

; <label>:18                                      ; preds = %51, %0
  %19 = load i32, i32* %z, align 4
  %20 = load i32, i32* %target_len, align 4
  %21 = icmp slt i32 %19, %20
  br i1 %21, label %22, label %52

; <label>:22                                      ; preds = %18
  %23 = load i32, i32* %k, align 4
  %24 = icmp eq i32 %23, -1
  br i1 %24, label %37, label %25

; <label>:25                                      ; preds = %22
  %26 = load i32, i32* %z, align 4
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %27
  %29 = load i8, i8* %28, align 1
  %30 = sext i8 %29 to i32
  %31 = load i32, i32* %k, align 4
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %32
  %34 = load i8, i8* %33, align 1
  %35 = sext i8 %34 to i32
  %36 = icmp eq i32 %30, %35
  br i1 %36, label %37, label %46

; <label>:37                                      ; preds = %25, %22
  %38 = load i32, i32* %k, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %k, align 4
  %40 = load i32, i32* %z, align 4
  %41 = add nsw i32 %40, 1
  store i32 %41, i32* %z, align 4
  %42 = load i32, i32* %k, align 4
  %43 = load i32, i32* %z, align 4
  %44 = sext i32 %43 to i64
  %45 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %44
  store i32 %42, i32* %45, align 4
  br label %51

; <label>:46                                      ; preds = %25
  %47 = load i32, i32* %k, align 4
  %48 = sext i32 %47 to i64
  %49 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %48
  %50 = load i32, i32* %49, align 4
  store i32 %50, i32* %k, align 4
  br label %51

; <label>:51                                      ; preds = %46, %37
  br label %18

; <label>:52                                      ; preds = %18
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %flag, align 4
  br label %53

; <label>:53                                      ; preds = %52, %100
  br label %54

; <label>:54                                      ; preds = %89, %53
  %55 = load i32, i32* %i, align 4
  %56 = load i32, i32* %source_len, align 4
  %57 = icmp slt i32 %55, %56
  br i1 %57, label %58, label %62

; <label>:58                                      ; preds = %54
  %59 = load i32, i32* %j, align 4
  %60 = load i32, i32* %target_len, align 4
  %61 = icmp slt i32 %59, %60
  br label %62

; <label>:62                                      ; preds = %58, %54
  %63 = phi i1 [ false, %54 ], [ %61, %58 ]
  br i1 %63, label %64, label %90

; <label>:64                                      ; preds = %62
  %65 = load i32, i32* %j, align 4
  %66 = icmp eq i32 %65, -1
  br i1 %66, label %79, label %67

; <label>:67                                      ; preds = %64
  %68 = load i32, i32* %i, align 4
  %69 = sext i32 %68 to i64
  %70 = getelementptr inbounds [100 x i8], [100 x i8]* %source, i64 0, i64 %69
  %71 = load i8, i8* %70, align 1
  %72 = sext i8 %71 to i32
  %73 = load i32, i32* %j, align 4
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds [100 x i8], [100 x i8]* %target, i64 0, i64 %74
  %76 = load i8, i8* %75, align 1
  %77 = sext i8 %76 to i32
  %78 = icmp eq i32 %72, %77
  br i1 %78, label %79, label %84

; <label>:79                                      ; preds = %67, %64
  %80 = load i32, i32* %i, align 4
  %81 = add nsw i32 %80, 1
  store i32 %81, i32* %i, align 4
  %82 = load i32, i32* %j, align 4
  %83 = add nsw i32 %82, 1
  store i32 %83, i32* %j, align 4
  br label %89

; <label>:84                                      ; preds = %67
  %85 = load i32, i32* %j, align 4
  %86 = sext i32 %85 to i64
  %87 = getelementptr inbounds [100 x i32], [100 x i32]* %next_pose, i64 0, i64 %86
  %88 = load i32, i32* %87, align 4
  store i32 %88, i32* %j, align 4
  br label %89

; <label>:89                                      ; preds = %84, %79
  br label %54

; <label>:90                                      ; preds = %62
  %91 = load i32, i32* %j, align 4
  %92 = load i32, i32* %target_len, align 4
  %93 = icmp eq i32 %91, %92
  br i1 %93, label %94, label %99

; <label>:94                                      ; preds = %90
  %95 = load i32, i32* %i, align 4
  %96 = load i32, i32* %target_len, align 4
  %97 = sub nsw i32 %95, %96
  %98 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i32 0, i32 0), i32 %97)
  store i32 1, i32* %flag, align 4
  store i32 0, i32* %j, align 4
  br label %100

; <label>:99                                      ; preds = %90
  br label %101

; <label>:100                                     ; preds = %94
  br label %53

; <label>:101                                     ; preds = %99
  %102 = load i32, i32* %flag, align 4
  %103 = icmp eq i32 %102, 0
  br i1 %103, label %104, label %106

; <label>:104                                     ; preds = %101
  %105 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.3, i32 0, i32 0))
  br label %106

; <label>:106                                     ; preds = %104, %101
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

declare i32 @gets(...) #1

; Function Attrs: nounwind readonly
declare i64 @strlen(i8*) #2

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readonly }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}

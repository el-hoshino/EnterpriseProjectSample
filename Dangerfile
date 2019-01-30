# PR チェック結果を定義
class CheckResult

    attr_accessor :warnings, :errors, :title, :message

    def initialize(title)
        @warnings = 0
        @errors = 0
        @title = "## " + title
        @message = markdown_message_template
    end

    def markdown_message_template
        template = "確認項目 | 結果\n"
        template << "|--- | --- |\n"
        return template
    end

end

# Xcode_summary を導入して確認
def common_xcode_summary_check
    
    xcode_summary.ignored_files = 'Pods/**'
    xcode_summary.inline_mode = true
    xcode_summary.report 'xcodebuild.json'
    
end

# SwiftLint を導入して確認
def common_swiftlint_check
    
    swiftlint.config_file = '.swiftlint.yml'
    swiftlint.lint_files inline_mode: true
    
end

def is_develop_pr

    ## とりあえず develop 向けの PR は develop PR とみなす
    is_to_develop = github.branch_for_base == "develop"
    if is_to_develop
        return true
    else
        return false
    end

end

def is_release_pr

    ## とりあえず master 向けの PR は release PR とみなす
    is_to_master = github.branch_for_base == "master"
    if is_to_master
        return true
    else
        return false
    end

end

# develop PR レビュールーチン
def develop_pr_check

    result = CheckResult.new("develop PR チェック")

    ## PR は `feature/`、`refactor/` 、`fix/` もしくは `issue/` で始まるブランチから出す
    result.message << "PR From ブランチ確認 |"
    is_from_feature = github.branch_for_head.start_with?("feature/")
    is_from_refactor = github.branch_for_head.start_with?("refactor/")
    is_from_fix = github.branch_for_head.start_with?("fix/")
    is_from_issue = github.branch_for_head.start_with?("issue/")
    if is_from_feature || is_from_refactor || is_from_fix || is_from_issue
        result.message << ":o:\n"
    else
        fail "デベロップ PR は Feature、Refactor、Fix もしくは Issue ブランチから出してください。"
        result.message << ":x:\n"
        result.errors += 1
    end

    ## PR は `develop` ブランチへ出す
    result.message << "PR To ブランチ確認 |"
    is_to_develop = github.branch_for_base == "develop"
    if is_to_develop
        result.message << ":o:\n"
    else
        fail "デベロップ PR は develop ブランチへマージしてください。"
        result.message << ":x:\n"
        result.errors += 1
    end

    ## コミットにマージコミットを含めてはいけない
    result.message << "マージコミット無し確認 |"
    contains_merge_commits = git.commits.any? { |c| c.parents.length > 1 }
    unless contains_merge_commits
        result.message << ":o:\n"
    else
        fail "デベロップ PR は他のブランチをマージしないでください；必要に応じてリベースしてください。"
        result.message << ":x:\n"
        result.errors += 1
    end

    ## PR の修正 1,000 行超えてはいけない
    result.message << "修正量確認 |"
    is_fix_too_big = git.lines_of_code > 1_000
    unless is_fix_too_big
        result.message << ":o:\n"
    else
        warn "修正が多すぎます。PR を小さく分割してください。"
        result.message << ":heavy_exclamation_mark:\n"
        result.warnings += 1
    end
    
    ## Brewfile もしくは Mintfile に修正を加えたら、Bitrise のキャッシュ設定の更新ワーニングを出す
    result.message << "Brewfile 修正確認 |"
    contains_brewfile_modification = git.modified_files.include? "Brewfile"
    unless contains_brewfile_modification
        result.message << ":o:\n"
    else
        message "Brewfile に修正が入っています。Bitrise の Cache 設定の更新を忘れずに更新しましょう。"
        result.message << ":heavy_exclamation_mark:\n"
    end
    
    return result
    
end

# リリース時 master ブランチがマージされる時の PR レビュールーチン
def release_pr_check

    result = CheckResult.new("リリース PR チェック")

    ## PR は `develop` ブランチから出す
    result.message << "PR From ブランチ確認 |"
    is_from_develop = github.branch_for_head == "develop"
    if is_from_develop
        result.message += ":o:\n"
    else
        fail "リリース PR は develop ブランチから出してください。"
        result.message += ":x:\n"
        result.errors += 1
    end

    ## PR は `master` ブランチへ出す
    result.message << "PR To ブランチ確認 |"
    is_to_master = github.branch_for_base == "master"
    if is_to_master
        result.message += ":o:\n"
    else
        fail "リリース PR は master ブランチへ出してください。"
        result.message += ":x:\n"
        result.errors += 1
    end

    ##! TODO: バージョンとビルドの変更確認

    return result

end

# Main routine

## SwiftLint のワーニング等確認
common_swiftlint_check

## Xcode Summary のワーニング等確認
common_xcode_summary_check

## チェックルーチンの設定
if is_develop_pr
    check_result = develop_pr_check
elsif is_release_pr
    check_result = release_pr_check
end

if check_result
    markdown(check_result.title)
    markdown(check_result.message)

    if check_result.errors == 0 && check_result.warnings == 0
        message "よくできました:white_flower:"
    end

else
    fail "チェックルーチンが設定されていない PR です。PR を確認してください。"
end

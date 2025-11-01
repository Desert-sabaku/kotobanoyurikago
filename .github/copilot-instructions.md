# GitHub Copilot Instructions for Kotoba_no_yurikago (コトバのゆりかご)

## 1. Project Overview

This is a web application for creating, discussing, and sharing Japanese translations for foreign loanwords. (これは、借用語に対する日本語訳を考案・議論・共有するためのWebアプリケーションです。)

## 2. Core Technology Stack (最重要技術スタック)

**You MUST strictly adhere to this stack. DO NOT suggest alternatives.**
(あなたはこのスタックに厳密に従う必要があります。代替案を提案しないでください。)

* **Backend:** Ruby on Rails 8.x
* **Frontend:** Hotwire (Turbo + Stimulus)
* **CSS:** Tailwind CSS
* **Database:** PostgreSQL
* **Authentication:** `devise` gem
* **Authorization:** `pundit` gem

For detailed requirements, please refer to the [requirements specification](../docs/requirementsSpecification.md). (詳細な要件については、[要件仕様書](../docs/requirementsSpecification.md)を参照してください。)

For the wireframes, please refer to the images in `docs/design`. (ワイヤーフレームについては、`docs/design`の画像を参照してください。)

## 3. Key Architectural Principles (重要な設計原則)

### DO (実行すべきこと):

* **HTML-Over-the-Wire (Hotwire):** Always prioritize using Turbo (Turbo Drive, Turbo Frames, Turbo Streams) for UI updates. (UIの更新には、常にTurbo Drive, Frames, Streams を使用することを優先してください。)
* **Server-Side State:** All application state should be managed by Rails on the server. (すべての状態はサーバー上のRailsで管理します。)
* **Stimulus for JavaScript:** Only use Stimulus controllers for minimal client-side interactivity (e.g., toggling menus, showing/hiding elements). (クライアント側のインタラクティブな動作は、Stimulusコントローラーのみを使用してください。)
* **Use Tailwind Utilities:** Always use Tailwind CSS utility classes directly in the ERB files. Do not write custom CSS files. (TailwindのユーティリティクラスをERBに直接記述してください。カスタムCSSは書かないでください。)
* **Use Pundit Policies:** All authorization logic MUST be placed in `app/policies/` using Pundit. Do not write authorization logic directly in controllers. (すべての認可ロジックは Pundit を使い `app/policies/` に配置してください。)

### DON'T (禁止事項):

* **NO React/Vue/Svelte:** DO NOT suggest using JavaScript frameworks like React, Vue, or Svelte. (ReactやVueのようなJSフレームワークを提案しないでください。)
* **NO JSON APIs:** DO NOT suggest creating JSON APIs for the frontend. We use Hotwire, not fetch/axios. (フロントエンドのためのJSON APIを提案しないでください。fetch/axiosではなくHotwireを使います。)
* **NO Bootstrap:** DO NOT suggest Bootstrap class names (e.g., `btn-primary`). We use Tailwind CSS. (Bootstrapのクラス名を提案しないでください。)

## 4. Database Schema (データベース定義)

Refer to these models when generating code: (コード生成時はこれらのモデルを参照してください。)

* `User(email, username)`
* `Subject(title, description, user_id)`: The topic word (e.g., "Sustainability")
* `Proposal(term, reasoning, subject_id, user_id)`: The suggested translation (e.g., "未来継承")
* `Vote(user_id, proposal_id)`: "Like" for a proposal
* `DiscussionTopic(title, body, user_id, discussable_type, discussable_id)`: A discussion thread
* `Comment(body, discussion_topic_id, user_id, parent_comment_id)`: A reply to a topic

## 5. Example Code Snippets (コード例)

### Good (Stimulus Controller)

```ruby
# app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "content" ]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
````

### Good (Turbo Stream Update)

```ruby
# app/controllers/comments_controller.rb
def create
  @comment = @discussion_topic.comments.build(comment_params)
  # ...
  respond_to do |format|
    if @comment.save
      format.turbo_stream
    else
      # ...
    end
  end
end
```

```erb
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append "comments_list", partial: "comments/comment", locals: { comment: @comment } %>
```

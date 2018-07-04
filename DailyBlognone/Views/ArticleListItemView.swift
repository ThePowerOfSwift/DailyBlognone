//
//  ArticleListItemView.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import ViewElements

final class ArticleListItemView: BaseNibView, OptionalTypedPropsAccessible {

    typealias PropsType = (title: String, subTitle: String)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    override func update() {
        titleLabel.text = props?.title
        subTitleLabel.text = props?.subTitle
    }
}

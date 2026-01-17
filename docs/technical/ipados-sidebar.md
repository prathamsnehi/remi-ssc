### [Integrate the tab bar and sidebar](https://developer.apple.com/documentation/uikit/elevating-your-ipad-app-with-a-tab-bar-and-sidebar#Integrate-the-tab-bar-and-sidebar)

Although both tab bars and sidebars play a similar navigation role in iPadOS apps, they have different strengths. A tab bar is always available and represents the key parts of your app. A sidebar provides a richer collection of possible destinations; however, people typically need to navigate back to the sidebar to select a different option.

If your app contains a rich hierarchy of views, you can create an array of tab items that the system displays as either a tab bar or a sidebar. This combination provides the best features of both navigation styles. When displaying as a tab bar, people have quick access to the most critical sections of your app. When displaying as a sidebar, they can see the full range and depth of your app.

Use [`UITab`](https://developer.apple.com/documentation/uikit/uitab) and [`UITabGroup`](https://developer.apple.com/documentation/uikit/uitabgroup) classes to create a hierarchy of tabs. If the tabs array contains at least one tab group, the system automatically displays the tabs as both a tab bar and a sidebar. Otherwise, it only displays the array as a tab bar. You can also explicitly define how the system displays your tabs by setting the [`UITabBarController`](https://developer.apple.com/documentation/uikit/uitabbarcontroller) object’s [`mode`](https://developer.apple.com/documentation/uikit/uitabbarcontroller/mode-swift.property) property.

```javascript
// Enable the sidebar.
tabBarController.mode = .tabSidebar


// Get the sidebar.
let sidebar = tabBarController.sidebar


// Show the sidebar.
sidebar.isHidden = false

```

By default, the system presents the sidebar in landscape orientation and hides it in portrait orientation; however, people can toggle between the tab bar and sidebar in either orientation. You can also programmatically show and hide the sidebar by setting its [`isHidden`](https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/ishidden) property.

### [Build a hierarchy of items for the sidebar](https://developer.apple.com/documentation/uikit/elevating-your-ipad-app-with-a-tab-bar-and-sidebar#Build-a-hierarchy-of-items-for-the-sidebar)

You can use [`UITabGroup`](https://developer.apple.com/documentation/uikit/uitabgroup) to define a section of items in the sidebar. Provide an array of tabs for the section’s content and a view controller to display when someone selects the section from the tab bar.

```javascript
let sectionOne = UITabGroup(
    title: "Section 1",
    image: UIImage(systemName: "1.square.fill"),
    identifier: "Section one",
    children:
        [
            UITab(
                title: "Subitem A",
                image: UIImage(systemName: "a.circle"),
                identifier: "Section 1, item A"
            ) { _ in
                MyFirstSubitemTabViewController()
            },

            UITab(
                title: "Subitem B",
                image: UIImage(systemName: "b.circle"),
                identifier: "Section 1, item b"
            ) { _ in
                MySecondSubitemTabViewController()
            },

            UITab(
                title: "Subitem C",
                image: UIImage(systemName: "c.circle"),
                identifier: "Section 1, item C"
            ) { _ in
                MyThirdSubitemTabViewController()
            },
        ]) { _ in
            // Return a view controller that the system displays when someone selects the section in the tab bar.
            MySectionViewController()
        }

```

The tab bar displays a tab group as a single tab item, and the sidebar displays it as a section that contains subitems. The sidebar displays top-level tab items first, followed by the sections.

You can nest a [`UITabGroup`](https://developer.apple.com/documentation/uikit/uitabgroup) inside another [`UITabGroup`](https://developer.apple.com/documentation/uikit/uitabgroup) to create a deeper hierarchy in the sidebar; however, consider limiting your app to two, or at most three, layers. Also, you can dynamically change a tab group’s content at runtime by modifying its [`children`](https://developer.apple.com/documentation/uikit/uitabgroup/children) property.

### [Add actions to the sidebar](https://developer.apple.com/documentation/uikit/elevating-your-ipad-app-with-a-tab-bar-and-sidebar#Add-actions-to-the-sidebar)

You can add actions to the sidebar by setting a tab group’s [`sidebarActions`](https://developer.apple.com/documentation/uikit/uitabgroup/sidebaractions) property. These actions function like buttons that you place inside the tab group.

```javascript
// Create the action.
let refreshAction = UIAction(title: "Refresh", image: UIImage(systemName: "arrow.clockwise")) { _ in
    myAction()
}


// Assign the action.
sectionOne.sidebarActions = [refreshAction]

```

To support swipe actions or context menus, assign a delegate to your sidebar that adopts the [`UITabBarController.Sidebar.Delegate`](https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/delegate-swift.protocol) protocol, and implement the following optional methods:

- [`tabBarController(_:sidebar:leadingSwipeActionsConfigurationFor:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/delegate-swift.protocol/tabbarcontroller(_:sidebar:leadingswipeactionsconfigurationfor:)>)
- [`tabBarController(_:sidebar:trailingSwipeActionsConfigurationFor:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/delegate-swift.protocol/tabbarcontroller(_:sidebar:trailingswipeactionsconfigurationfor:)>)
- [`tabBarController(_:sidebar:contextMenuConfigurationFor:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/delegate-swift.protocol/tabbarcontroller(_:sidebar:contextmenuconfigurationfor:)>)

To support drag-and-drop operations, assign a delegate to your tab bar that adopts the [`UITabBarControllerDelegate`](https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate) protocol, and implement the [`tabBarController(_:tab:operationForAcceptingItemsFrom:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate/tabbarcontroller(_:tab:operationforacceptingitemsfrom:)>) and [`tabBarController(_:tab:acceptItemsFrom:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate/tabbarcontroller(_:tab:acceptitemsfrom:)>) methods.

### [Enable customization](https://developer.apple.com/documentation/uikit/elevating-your-ipad-app-with-a-tab-bar-and-sidebar#Enable-customization)

People can customize the content in both the tab bar and sidebar using a system-provided button that puts the bars into edit mode. While editing, people can:

- Drag items from the sidebar to the tab bar to add them to the tab bar.
- Drag items from the tab bar to remove them from the tab bar.
- Drag items to reorder them in the tab bar.
- Drag items to reorder them inside their tab group.
- Uncheck items in the sidebar to hide them. This also removes them from the tab bar.

The system automatically persists any customizations that someone makes to the bars. You can implement the [`tabBarController(_:displayOrderDidChangeFor:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate/tabbarcontroller(_:displayorderdidchangefor:)>) and [`tabBarController(_:visibilityDidChangeFor:)`](<https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate/tabbarcontroller(_:visibilitydidchangefor:)>) delegate methods to receive notifications about the changes.

By default, only the top-level tabs appear in the tab bar. People can add or remove any tab in the sidebar, but can’t hide or reorder the items in it.

To control which items appear in the tab bar, and how people can customize them, set the [`UITab`](https://developer.apple.com/documentation/uikit/uitab) object’s [`preferredPlacement`](https://developer.apple.com/documentation/uikit/uitab/preferredplacement) property. Conceptually, you can think of the tab bar as having three different regions:

- Fixed tabs appear on the leading edge of the tab bar.
- Default, optional, and movable tabs appear after the fixed tabs.
- Pinned tabs are always visible on the trailing edge, and only show the tab’s image.

When possible, make tabs customizable so that people can choose which ones to place in the tab bar. If you have any tabs that are central to your app, consider making them fixed tabs, so that people can’t remove or move them. Use pinned tabs for prominent items, like search. Also, because pinned tabs only display the tab icon, be sure to select an image that people recognize and can easily understand.

To create an item that appears in the sidebar, but that people can’t add to the tab bar, set the [`preferredPlacement`](https://developer.apple.com/documentation/uikit/uitab/preferredplacement) property to [`UITab.Placement.sidebarOnly`](https://developer.apple.com/documentation/uikit/uitab/placement/sidebaronly). To create an item that people can add to or remove from the sidebar, set its [`allowsHiding`](https://developer.apple.com/documentation/uikit/uitab/allowshiding) property to [`true`](https://developer.apple.com/documentation/Swift/true). If someone removes an item from the sidebar, the system also removes it from the tab bar.

```javascript
// Create the tab.
var customizeableItem = UITab(
        title: "Optional",
        image: UIImage(systemName: "questionmark.app"),
        identifier: "Optional Item"
) { _ in
    MyOptionalViewController()
}


// Let people add and remove this item in the sidebar.
customizeableItem.allowsHiding = true


// Set the item as hidden in the sidebar by default.
customizeableItem.isHiddenByDefault = true
```

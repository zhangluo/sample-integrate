// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract CrowdfundingPlatform is UUPSUpgradeable, OwnableUpgradeable {
    struct Project {
        address payable creator;
        string description;
        uint256 goalAmount;
        uint256 deadline;
        uint256 currentAmount;
        bool withdrawn;
        mapping(address => uint256) contributions;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    event ProjectCreated(uint256 indexed projectId, address indexed creator, string description, uint256 goalAmount, uint256 deadline);
    event ContributionMade(uint256 indexed projectId, address indexed contributor, uint256 amount);
    event FundsWithdrawn(uint256 indexed projectId, address indexed creator, uint256 amount);
    event FundsRefunded(uint256 indexed projectId, address indexed contributor, uint256 amount);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function createProject(string calldata description, uint256 goalAmount, uint256 durationInDays) external {
        require(goalAmount > 0, "Goal amount should be greater than 0");
        require(durationInDays > 0, "Duration should be greater than 0");

        uint256 deadline = block.timestamp + (durationInDays * 1 days);
        projectCount++;

        Project storage newProject = projects[projectCount];
        newProject.creator = payable(msg.sender);
        newProject.description = description;
        newProject.goalAmount = goalAmount;
        newProject.deadline = deadline;
        newProject.currentAmount = 0;
        newProject.withdrawn = false;

        emit ProjectCreated(projectCount, msg.sender, description, goalAmount, deadline);
    }

    function contribute(uint256 projectId) external payable {
        require(projectId > 0 && projectId <= projectCount, "Invalid project ID");
        Project storage project = projects[projectId];
        require(block.timestamp < project.deadline, "Project has expired");
        require(msg.value > 0, "Contribution should be greater than 0");

        project.contributions[msg.sender] += msg.value;
        project.currentAmount += msg.value;

        emit ContributionMade(projectId, msg.sender, msg.value);
    }

    function getProjectStatus(uint256 projectId) public view returns (string memory) {
        require(projectId > 0 && projectId <= projectCount, "Invalid project ID");
        Project storage project = projects[projectId];

        if (block.timestamp >= project.deadline) {
            if (project.currentAmount >= project.goalAmount) {
                return "Success";
            } else {
                return "Failure";
            }
        } else {
            return "Ongoing";
        }
    }

    function withdrawFunds(uint256 projectId) external {
        require(projectId > 0 && projectId <= projectCount, "Invalid project ID");
        Project storage project = projects[projectId];
        require(msg.sender == project.creator, "Only project creator can withdraw funds");
        require(block.timestamp >= project.deadline, "Project is still ongoing");
        require(project.currentAmount >= project.goalAmount, "Project did not reach the goal");
        require(!project.withdrawn, "Funds already withdrawn");

        project.withdrawn = true;
        project.creator.transfer(project.currentAmount);

        emit FundsWithdrawn(projectId, msg.sender, project.currentAmount);
    }

    function refund(uint256 projectId) external {
        require(projectId > 0 && projectId <= projectCount, "Invalid project ID");
        Project storage project = projects[projectId];
        require(block.timestamp >= project.deadline, "Project is still ongoing");
        require(project.currentAmount < project.goalAmount, "Project reached the goal");
        
        uint256 amount = project.contributions[msg.sender];
        require(amount > 0, "No contributions found for this user");

        project.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit FundsRefunded(projectId, msg.sender, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}